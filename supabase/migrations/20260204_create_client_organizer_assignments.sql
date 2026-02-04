-- Create client_organizer_assignments table
CREATE TABLE IF NOT EXISTS public.client_organizer_assignments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    client_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    organizer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    assigned_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT client_organizer_assignments_status_check CHECK (status IN ('active', 'completed', 'cancelled'))
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_client_organizer_assignments_client_id 
ON public.client_organizer_assignments(client_id);

CREATE INDEX IF NOT EXISTS idx_client_organizer_assignments_organizer_id 
ON public.client_organizer_assignments(organizer_id);

CREATE INDEX IF NOT EXISTS idx_client_organizer_assignments_status 
ON public.client_organizer_assignments(status);

-- Add RLS (Row Level Security) policies
ALTER TABLE public.client_organizer_assignments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own assignments (as client or organizer)
CREATE POLICY "Users can view their own assignments"
ON public.client_organizer_assignments
FOR SELECT
USING (
    auth.uid() = client_id OR 
    auth.uid() = organizer_id
);

-- Policy: Only organizers can create assignments
CREATE POLICY "Organizers can create assignments"
ON public.client_organizer_assignments
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE user_id = auth.uid() AND role = 'organizer'
    )
);

-- Policy: Only organizers can update assignments
CREATE POLICY "Organizers can update assignments"
ON public.client_organizer_assignments
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE user_id = auth.uid() AND role = 'organizer'
    )
);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.client_organizer_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add comment for documentation
COMMENT ON TABLE public.client_organizer_assignments IS 'Tracks which organizer is assigned to which client for load balancing';
COMMENT ON COLUMN public.client_organizer_assignments.status IS 'Status: active (currently assigned), completed (event finished), cancelled (assignment cancelled)';
