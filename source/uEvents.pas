unit uEvents;

interface

uses
  Classes;

type
  TOnKeyDown = procedure (Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TOnEnter = procedure (Sender: TObject) of object;
  TOnExit = procedure (Sender: TObject) of object;

implementation

end.
