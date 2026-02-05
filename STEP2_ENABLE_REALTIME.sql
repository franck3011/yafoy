-- ============================================
-- STEP 2: Enable Realtime
-- Execute this AFTER Step 1
-- ============================================

-- Try to add tables to realtime publication
-- If you get "already exists" errors, that's OK - it means it's already enabled
DO $$
BEGIN
  -- Add chat_messages
  BEGIN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages';
  EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'chat_messages already in publication';
  END;

  -- Add chat_rooms
  BEGIN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms';
  EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'chat_rooms already in publication';
  END;

  -- Add chat_room_participants
  BEGIN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE chat_room_participants';
  EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'chat_room_participants already in publication';
  END;
END $$;

-- Verify realtime is enabled
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
AND tablename IN ('chat_messages', 'chat_rooms', 'chat_room_participants');
