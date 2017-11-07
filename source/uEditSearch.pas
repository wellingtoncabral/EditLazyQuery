unit uEditSearch;

interface

uses
  StdCtrls, Messages;

type
  TEditSearch = class(TEdit)
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  end;

implementation

uses
  Windows;

{ TEditSearch }

procedure TEditSearch.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  //Message.Result := Message.Result or DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS or DLGC;
  Message.Result := Message.Result or DLGC_WANTTAB or DLGC_WANTARROWS;
end;

end.
