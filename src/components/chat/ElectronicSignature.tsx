import { useRef, useState } from 'react';
import ReactSignatureCanvas from 'react-signature-canvas';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Pen, Loader2, RotateCcw } from 'lucide-react';

interface ElectronicSignatureProps {
    isOpen: boolean;
    onClose: () => void;
    onSign: (signatureUrl: string) => Promise<void>;
    isSigning: boolean;
}

export const ElectronicSignature = ({ isOpen, onClose, onSign, isSigning }: ElectronicSignatureProps) => {
    const sigPad = useRef<ReactSignatureCanvas>(null);
    const [isEmpty, setIsEmpty] = useState(true);

    const clear = () => {
        sigPad.current?.clear();
        setIsEmpty(true);
    };

    const handleSign = async () => {
        if (isEmpty || !sigPad.current) return;

        // Convert canvas to data URL (PNG)
        const signatureData = sigPad.current.getTrimmedCanvas().toDataURL('image/png');

        // Call onSign prop
        await onSign(signatureData);
    };

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="sm:max-w-md">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                        <Pen className="h-5 w-5" />
                        Signature de l'accord
                    </DialogTitle>
                    <DialogDescription>
                        Veuillez signer ci-dessous pour confirmer votre accord avec l'organisateur.
                    </DialogDescription>
                </DialogHeader>

                <div className="border-2 border-dashed border-gray-300 rounded-lg p-1 bg-gray-50">
                    <ReactSignatureCanvas
                        ref={sigPad}
                        penColor="black"
                        onBegin={() => setIsEmpty(false)}
                        canvasProps={{
                            width: 400,
                            height: 200,
                            className: 'cursor-crosshair w-full h-[200px] bg-white rounded-md'
                        }}
                    />
                </div>

                <DialogFooter className="flex justify-between sm:justify-between w-full">
                    <Button
                        type="button"
                        variant="ghost"
                        onClick={clear}
                        disabled={isSigning || isEmpty}
                        className="text-muted-foreground"
                    >
                        <RotateCcw className="h-4 w-4 mr-2" />
                        Effacer
                    </Button>

                    <div className="flex gap-2">
                        <Button
                            type="button"
                            variant="outline"
                            onClick={onClose}
                            disabled={isSigning}
                        >
                            Annuler
                        </Button>
                        <Button
                            type="button"
                            onClick={handleSign}
                            disabled={isSigning || isEmpty}
                        >
                            {isSigning ? (
                                <>
                                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                    Envoi...
                                </>
                            ) : (
                                'Envoyer la signature'
                            )}
                        </Button>
                    </div>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
};
