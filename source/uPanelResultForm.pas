unit uPanelResultForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TfrmPanelResult = class(TForm)
    procedure FormShow(Sender: TObject);

  private
    FControlFocus: TWinControl;
    { Private declarations }
  public
    property ControlFocus: TWinControl read FControlFocus write FControlFocus;
  end;

var
  frmPanelResult: TfrmPanelResult;

implementation

{$R *.dfm}

procedure TfrmPanelResult.FormShow(Sender: TObject);
begin
  if Assigned(FControlFocus) then
  begin
    FControlFocus.SetFocus;
  end;
end;

end.
