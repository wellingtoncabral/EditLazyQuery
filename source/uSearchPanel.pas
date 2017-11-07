unit uSearchPanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Graphics, StdCtrls, Forms, DB, uEvents,
  uColumnItem, Menus, Clipbrd, uEditSearch;

type

  TOnTextChange = procedure(Text: string) of object;
  TOnPopupItemClick = procedure(ItemIndex: Integer; Checked: Boolean) of object;
  TOnPopupClick = procedure of object;

  TSearchPanel = class(TPanel)
  private
    FImgLupa         : TImage;
    FImgOptions      : TImage;
    FDisplaySearching: TPanel;
    FEditSearch      : TEditSearch;
    FOnTextChange    : TOnTextChange;
    FOnEditKeyDown   : TOnKeyDown;
    FOnPopupItemClick: TOnPopupItemClick;
    FPopupItens      : TPopupMenu;
    FLabelKey        : TLabel;
    FOnPopupClick    : TOnPopupClick;

    procedure InitImgLupa;
    procedure InitImgOptions;
    procedure InitLabelKey;
    procedure InitDisplaySearching;
    procedure InitEditSearch;
    procedure InitPopupItens;
    procedure SetText(const Value: string);

    procedure DoOnTextChange(Sender: TObject);
    procedure DoOnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnImgOptionsClick(Sender: TObject);
    procedure DoPopupItemClick(Sender: TObject);
    procedure DoLabelKeyClick(Sender: TObject);

    function GetText: string;
    function GetShowColumnList: Boolean;
    procedure SetShowColumnList(const Value: Boolean);

    //procedure CMDialogKey(var msg: TCMDialogKey); message CM_DIALOGKEY;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDisplaySearching(Text: string);
    procedure ShowDisplaySearching(Display: string);
    procedure HideDisplaySearching;
    procedure AddPopupItem(Caption: string; Checked: Boolean);
    procedure SetFocusEdit;
    procedure ShowLabelKey(Value: Boolean);
    procedure SetCaptionLabelKey(Value: string);
    procedure SetColor(Value: TColor);

    property Text: string read GetText write SetText;
    property ShowColumnList: Boolean read GetShowColumnList write SetShowColumnList;
    property EditSearch: TEditSearch read FEditSearch;
    property LabelKey: TLabel read FLabelKey;
    property OnTextChange: TOnTextChange read FOnTextChange write FOnTextChange;
    property OnEditKeyDown: TOnKeyDown read FOnEditKeyDown write FOnEditKeyDown;
    property OnPopupClick: TOnPopupClick read FOnPopupClick write FOnPopupClick;
    property OnPopupItemClick: TOnPopupItemClick read FOnPopupItemClick write FOnPopupItemClick;
  end;

implementation

uses
  Types, Windows, Messages;

{$R ResEditLateQuery.RES}

{ TSearchPanel }

procedure TSearchPanel.AddPopupItem(Caption: string; Checked: Boolean);
var
  MenuItem: TMenuItem;
begin
  MenuItem         := TMenuItem.Create(FPopupItens);
  MenuItem.Caption := Caption;
  MenuItem.Checked := Checked;
  MenuItem.OnClick := DoPopupItemClick;
  FPopupItens.Items.Add(MenuItem);
end;

{procedure TSearchPanel.CMDialogKey(var msg: TCMDialogKey);
var
  Key: Word;
begin
  if msg.Charcode <> VK_TAB then
  begin
    inherited;
  end
  else
  begin
    if Assigned(FOnEditKeyDown) then
    begin
      Key := VK_TAB;
      DoOnEditKeyDown(FEditSearch, Key, []);
    end;
  end;
end;}

constructor TSearchPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.BevelOuter       := bvNone;
  Self.Height           := 22;
  Self.Color            := clWhite;
  Self.ParentBackground := False;
  Self.ParentFont       := False;
  Self.TabOrder         := 0;
  Self.Margins.Left     := 1;
  Self.Margins.Top      := 1;
  Self.Margins.Right    := 1;
  Self.Margins.Bottom   := 0;
  Self.TabStop          := False;

  InitLabelKey;
  InitImgLupa;
  InitImgOptions;
  InitEditSearch;
  InitDisplaySearching;
  InitPopupItens;
end;

destructor TSearchPanel.Destroy;
begin

  if Assigned(FPopupItens) then
  begin
    FreeAndNil(FPopupItens);
  end;

  if Assigned(FImgLupa) then
  begin
    FreeAndNil(FImgLupa);
  end;

  if Assigned(FImgOptions) then
  begin
    FreeAndNil(FImgOptions);
  end;

  if Assigned(FDisplaySearching) then
  begin
    FreeAndNil(FDisplaySearching);
  end;

  if Assigned(FEditSearch) then
  begin
    FreeAndNil(FEditSearch);
  end;

  inherited;
end;

procedure TSearchPanel.DoLabelKeyClick(Sender: TObject);
begin
  Clipboard.AsText := FLabelKey.Caption;
end;

procedure TSearchPanel.DoOnEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FOnEditKeyDown) then
  begin
    FOnEditKeyDown(Self, Key, Shift);
  end;
end;

procedure TSearchPanel.DoOnImgOptionsClick(Sender: TObject);
var
  Pnt: TPoint;
begin
  if Assigned(FOnPopupClick) then
  begin
    FOnPopupClick();
  end;

  if GetCursorPos(Pnt) then
  begin
    FPopupItens.Popup(Pnt.X, Pnt.Y);
  end;
end;

procedure TSearchPanel.DoOnTextChange(Sender: TObject);
begin
  if Assigned(FOnTextChange) then
  begin
    FOnTextChange(FEditSearch.Text);
  end;
end;

procedure TSearchPanel.DoPopupItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  i: Integer;
  CanCheck: Boolean;
begin
  CanCheck := False;

  MenuItem := TMenuItem(Sender);

  if MenuItem.Checked then
  begin
    for i := 0 to Pred(FPopupItens.Items.Count) do
    begin
      if (FPopupItens.Items[i] <> MenuItem) and FPopupItens.Items[i].Checked then
      begin
        CanCheck := True;
        Break;
      end;
    end;
  end
  else
  begin
    CanCheck := True;
  end;

  if CanCheck then
  begin
    MenuItem.Checked := not MenuItem.Checked;

    if Assigned(FOnPopupItemClick) then
    begin
      FOnPopupItemClick(MenuItem.MenuIndex, MenuItem.Checked);
    end;
  end;
end;

function TSearchPanel.GetShowColumnList: Boolean;
begin
  Result := FImgOptions.Visible;
end;

function TSearchPanel.GetText: string;
begin
  Result := FEditSearch.Text;
end;

procedure TSearchPanel.HideDisplaySearching;
begin
  FDisplaySearching.Visible := False;
end;

procedure TSearchPanel.InitDisplaySearching;
begin
  FDisplaySearching            := TPanel.Create(Self);
  FDisplaySearching.Parent     := Self;
  FDisplaySearching.SetSubComponent(False);
  FDisplaySearching.Align      := alClient;
  FDisplaySearching.Alignment  := taLeftJustify;
  FDisplaySearching.BevelOuter := bvNone;
  FDisplaySearching.Caption    := 'Pesquisando...';
  FDisplaySearching.Font.Color := clGray;
  FDisplaySearching.Visible    := False;
  FDisplaySearching.SendToBack;
end;

procedure TSearchPanel.InitEditSearch;
begin
  FEditSearch                  := TEditSearch.Create(Self);
  FEditSearch.Parent           := Self;
  FEditSearch.SetSubComponent(False);
  FEditSearch.AlignWithMargins := True;
  FEditSearch.Margins.Left     := 0;
  FEditSearch.Margins.Right    := 0;
  FEditSearch.Margins.Bottom   := 0;
  FEditSearch.Align            := alClient;
  FEditSearch.BorderStyle      := bsNone;
  FEditSearch.TabOrder         := 0;
  FEditSearch.OnChange         := DoOnTextChange;
  FEditSearch.OnKeyDown        := DoOnEditKeyDown;
end;

procedure TSearchPanel.InitImgLupa;
begin
  FImgLupa                  := TImage.Create(Self);
  FImgLupa.Parent           := Self;
  FImgLupa.SetSubComponent(False);
  FImgLupa.AlignWithMargins := True;
  FImgLupa.Left             := -100;
  FImgLupa.Top              := 3;
  FImgLupa.Width            := 16;
  FImgLupa.Height           := 16;
  FImgLupa.Margins.Left     := 5;
  FImgLupa.Align            := alLeft;
  FImgLupa.AutoSize         := True;
  FImgLupa.Center           := True;
  FImgLupa.Transparent      := True;
  FImgLupa.Picture.Bitmap.LoadFromResourceName(HInstance, 'SEARCH');
end;

procedure TSearchPanel.InitImgOptions;
begin
  FImgOptions                  := TImage.Create(Self);
  FImgOptions.Parent           := Self;
  FImgOptions.SetSubComponent(False);
  FImgOptions.AlignWithMargins := True;
  FImgOptions.Left             := 372;
  FImgOptions.Top              := 3;
  FImgOptions.Width            := 16;
  FImgOptions.Height           := 16;
  FImgOptions.Cursor           := crHandPoint;
  FImgOptions.Margins.Left     := 5;
  FImgOptions.Align            := alRight;
  FImgOptions.AutoSize         := True;
  FImgOptions.Center           := True;
  FImgOptions.Transparent      := True;
  FImgOptions.OnClick          := DoOnImgOptionsClick;
  FImgOptions.Picture.Bitmap.LoadFromResourceName(HInstance, 'LIST');
end;

procedure TSearchPanel.InitLabelKey;
begin
  FLabelKey                  := TLabel.Create(Self);
  FLabelKey.Parent           := Self;
  FLabelKey.SetSubComponent(False);
  FLabelKey.Left             := 5;
  FLabelKey.Visible          := False;
  FLabelKey.AutoSize         := True;
  FLabelKey.AlignWithMargins := True;
  FLabelKey.Margins.Left     := 0;
  FLabelKey.Margins.Top      := 0;
  FLabelKey.Margins.Right    := 4;
  FLabelKey.Margins.Bottom   := 0;
  FLabelKey.Align            := alLeft;
  FLabelKey.Caption          := '';
  FLabelKey.Font.Color       := clHighlight;
  FLabelKey.Font.Size        := 8;
  FLabelKey.Font.Style       := [fsBold];
  FLabelKey.ParentColor      := False;
  FLabelKey.ParentFont       := False;
  FLabelKey.Transparent      := True;
  FLabelKey.Layout           := tlCenter;
  FLabelKey.Cursor           := crHandPoint;
  FLabelKey.OnClick          := DoLabelKeyClick;
end;

procedure TSearchPanel.InitPopupItens;
begin
  FPopupItens := TPopupMenu.Create(Self);
  FPopupItens.SetSubComponent(False);
end;

procedure TSearchPanel.SetCaptionLabelKey(Value: string);
begin
  FLabelKey.Caption := Value;
end;

procedure TSearchPanel.SetColor(Value: TColor);
begin
  Self.Color        := Value;
  FEditSearch.Color := Value;
end;

procedure TSearchPanel.SetDisplaySearching(Text: string);
begin
  FDisplaySearching.Caption := Text;
end;

procedure TSearchPanel.SetFocusEdit;
begin
  PostMessage(FEditSearch.Handle, WM_KILLFOCUS, 0, 0);
  PostMessage(FEditSearch.Handle, WM_SETFOCUS, 0, 0);
  FEditSearch.SetFocus;
end;

procedure TSearchPanel.SetShowColumnList(const Value: Boolean);
begin
  FImgOptions.Visible := Value;

  if (not Value) and (csDesigning in ComponentState) then
  begin
    FImgOptions.AutoSize := False;
    FImgOptions.Width    := 0;
    FImgOptions.Height   := 0;
  end
  else
  begin
    FImgOptions.AutoSize := True;
  end;

end;

procedure TSearchPanel.SetText(const Value: string);
begin
  FEditSearch.Text := Value;
end;

procedure TSearchPanel.ShowDisplaySearching(Display: string);
begin
  FDisplaySearching.Caption := Display;
  FDisplaySearching.Visible := True;
  FDisplaySearching.BringToFront;
end;


procedure TSearchPanel.ShowLabelKey(Value: Boolean);
begin
  FLabelKey.Visible := Value;
  FImgLupa.Left     := -100;
end;

end.
