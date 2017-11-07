unit uEditLazyQuery;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Graphics, uSearchPanel, DB, Forms,
  uGridResult, uColumnCollection, uEvents, StdCtrls, uPanelResult, Windows;

type
  TLabelAlign = (laLeft, laRight);
  TOnGetRecordCount = procedure(var RecordCount: Integer) of object;
  TOnSearch = procedure(Text: string; AStartRowNum, AEndRowNum: Integer) of object;
  TOnSearchByKeyValue = procedure(AKeyValue: OleVariant) of object;

  TEditLazyQuery = class(TCustomPanel)
  private
    FTimer               : TTimer;
    FDelay               : Integer;
    FSearchPanel         : TSearchPanel;
    FPanelResult         : TPanelResult;
    FDataSet             : TDataSet;
    FOnSearch            : TOnSearch;
    FTimeOut             : TTime;
    FLastSearch          : string;
    FColumns             : TColumnCollection;
    FBuildedColumns      : Boolean;
    FKeyFieldName        : string;
    FKeyValue            : OleVariant;
    FDisplayFieldName    : string;
    FActive              : Boolean;
    FShowColumnList      : Boolean;
    FShowKeyInLabel      : Boolean;
    FOnEnter             : TOnEnter;
    FOnExit              : TOnExit;
    FOnEditKeyDown       : TOnKeyDown;
    FShapeHide           : TShape;
    FBackgroundColor     : TColor;

    FOldTop              : Integer;
    FOrietationWasChanged: Boolean;
    FOnGetRecordCount    : TOnGetRecordCount;
    FOnSearchByKeyValue  : TOnSearchByKeyValue;
    FPageSize            : Integer;
    FGridWidth           : Integer;
    FGridHeight          : Integer;
    FActiveLazy          : Boolean;
    FActiveEvents        : Boolean;
    FGridIsFocus         : Boolean;
    FShowRecordsEmptyText: Boolean;
    FRequired            : Boolean;

    procedure InitTimer;
    procedure InitSearcPanel;
    procedure InitGrid;

    procedure SetDelay(const Value: Integer);
    procedure ShowGrid;
    procedure HideGrid;
    procedure SetText(const Value: string);
    procedure BuildColumns;
    procedure Search(Text: string);
    procedure DoSearch(Text: string; RequireRowsCount: Boolean = True);
    procedure GetSelectedItem;
    procedure CalcOrientation;

    function GetTopParentForm(Control: TControl): Integer;
    function GetLeftParentForm(Control: TControl): Integer;
    function GetText: string;
    function DataSetIsActivated: Boolean;
    function GridIsShowed: Boolean;

    procedure DoOnTextChangeTimer(Sender: TObject);
    procedure DoOnTextChange(Text: string);
    procedure DoOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnPopupClick;
    procedure DoOnPopupItemClick(ItemIndex: Integer; Checked: Boolean);
    procedure DoOnGridDblClick;
    procedure DoOnGetRecords(StatusRecord: TStatusRecord);
    procedure DoOnPageButtonClick(Sender: TPageButton);
    procedure DoOnPanelResultExit(Sender: TObject);

    procedure SetDataSet(const Value: TDataSet);
    procedure SetActive(const Value: Boolean);
    procedure SetShowColumnList(const Value: Boolean);
    function GetTextHint: string;
    procedure SetTextHint(const Value: string);
    function GetKeyFieldColor: TColor;
    procedure SetKeyFieldColor(const Value: TColor);
    function GetKeyLabelPosition: TLabelAlign;
    procedure SetKeyLabelPosition(const Value: TLabelAlign);
    procedure SetKeyValue(const Value: OleVariant);
    procedure NextControlFocus;
    procedure PreviousControlFocus;

    // PanelResultForm
    function PanelResultFormIsShowing: Boolean;
    procedure ClosePanelResultForm;
    procedure OpenPanelResultForm;
    procedure InitShapeHide;
    procedure MaximizePanelResultForm;

    procedure SetPageSize(const Value: Integer);
    function GetCharCase: TEditCharCase;
    procedure SetCharCase(const Value: TEditCharCase);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
    procedure EmptyDataSet;
    function GetMaxLength: Integer;
    procedure SetMaxLength(const Value: Integer);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetActiveLazy(const Value: Boolean);
  protected
    procedure DoExit; override;
    procedure DoEnter; override;
    procedure Paint; override;
    procedure Process(Method: TProc);
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    function IsNull: Boolean;

    property KeyValue: OleVariant read FKeyValue write SetKeyValue;
  published
    property TabOrder;
    property TabStop;
    property Align;
    property Alignment;
    property Anchors;
    property Visible;
    property Text: string read GetText write SetText;
    property KeyFieldName: string read FKeyFieldName write FKeyFieldName;
    property DisplayFieldName: string read FDisplayFieldName write FDisplayFieldName;
    property Delay: Integer read FDelay write SetDelay;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property Columns: TColumnCollection read FColumns write FColumns;
    property Active: Boolean read FActive write SetActive;
    property ActiveLazy: Boolean read FActiveLazy write SetActiveLazy;
    property ShowColumnList: Boolean read FShowColumnList write SetShowColumnList;
    property ShowKeyInLabel: Boolean read FShowKeyInLabel write FShowKeyInLabel;
    property TextHint: string read GetTextHint write SetTextHint;
    property KeyFieldColor: TColor read GetKeyFieldColor write SetKeyFieldColor;
    property KeyLabelPosition: TLabelAlign read GetKeyLabelPosition write SetKeyLabelPosition;
    property PageSize: Integer read FPageSize write SetPageSize;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property GridWidth: Integer read FGridWidth write FGridWidth;
    property GridHeight: Integer read FGridHeight write FGridHeight;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property ShowRecordsEmptyText: Boolean read FShowRecordsEmptyText write FShowRecordsEmptyText;
    property Required: Boolean read FRequired write FRequired;

    // Events
    property OnSearch: TOnSearch read FOnSearch write FOnSearch;
    property OnSearchByKeyValue: TOnSearchByKeyValue read FOnSearchByKeyValue write FOnSearchByKeyValue;
    property OnEnter: TOnEnter read FOnEnter write FOnEnter;
    property OnExit: TOnExit read FOnExit write FOnExit;
    property OnGetRecordCount: TOnGetRecordCount read FOnGetRecordCount write FOnGetRecordCount;
    property OnEditKeyDown: TOnKeyDown read FOnEditKeyDown write FOnEditKeyDown;
  end;

const
  C_GRID_HEIGHT = 145;

procedure Register;

implementation

uses
  DateUtils, Variants, Messages, cxGridCustomView, uPanelResultForm;

procedure Register;
begin
  RegisterComponents('Agfa Data Controls', [TEditLazyQuery]);
end;

function GetInnermostParentForm(AControl: TControl): TForm;
begin
  while Assigned(Acontrol) and not (AControl is TForm) do
  begin
    AControl := AControl.Parent;
  end;
  Result := TForm(aControl);
end;


{ TEditLateQuery }

procedure TEditLazyQuery.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited;
  FSearchPanel.Height := Self.Height - 2;
end;

procedure TEditLazyQuery.BuildColumns;
var
  i, WidthAux: Integer;
begin
  if not FBuildedColumns then
  begin
    for i := 0 to FColumns.Count - 1 do
    begin
      WidthAux := Trunc((FColumns.Items[i].Percentage * Self.Width) / 100);

      FPanelResult.Grid.AddColumn(
        FColumns.Items[i].Caption,
        FColumns.Items[i].FieldName,
        WidthAux,
        FColumns.Items[i].Visible);

      FSearchPanel.AddPopupItem(
        FColumns.Items[i].Caption,
        FColumns.Items[i].Visible);
    end;
    FBuildedColumns := True;
  end;
end;

procedure TEditLazyQuery.CalcOrientation;
var
  TopForm, LeftForm: Integer;
  Form: TForm;
begin
  Form := GetInnermostParentForm(TWinControl(Owner));

  // Align on Top
  TopForm := GetTopParentForm(Self);
  if (TopForm + Self.Height + FPanelResult.Height)> Form.Height then
  begin
    FPanelResult.Top := TopForm - FPanelResult.Height;
  end
  else
  // Align on Bottom
  begin
    FPanelResult.Top := TopForm + Self.Height - 1;
  end;

  // Align on Left.
  LeftForm :=  GetLeftParentForm(Self);
  if (LeftForm + FPanelResult.Width) > Form.Width then
  begin
    FPanelResult.Left := LeftForm + Self.Width - FPanelResult.Width;
    if (FPanelResult.Left < 0) then
    begin
      FPanelResult.Left := LeftForm;
    end;
  end
  else
  begin
    FPanelResult.Left := LeftForm;
  end;

  // Checks if the Grid passed the screen size.
  if (FPanelResult.Left + FPanelResult.Width) > Form.Width then
  begin
    FPanelResult.Width := Form.Width - FPanelResult.Left - 33;
  end
  else
  begin
    if FGridWidth > -1 then
    begin
      FPanelResult.Width := FGridWidth;
    end
    else
    begin
      FPanelResult.Width := Self.Width;
    end;
  end;

  if FGridHeight > -1 then
  begin
    FPanelResult.Height := FGridHeight;
  end
  else
  begin
    FPanelResult.Height :=  C_GRID_HEIGHT;
  end;
end;

procedure TEditLazyQuery.Clear;
begin
  FActive := False;
  try
    Text        := EmptyStr;
    FKeyValue   := Null;
    FLastSearch := EmptyStr;
    EmptyDataSet;
    FSearchPanel.ShowLabelKey(False);
    HideGrid;
  finally
    FActive := True;
  end;
end;

procedure TEditLazyQuery.ClosePanelResultForm;
begin
  frmPanelResult.Close;
end;

constructor TEditLazyQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.DoubleBuffered   := True;

  FDelay                := 700;
  FBuildedColumns       := False;
  FActive               := True;
  FActiveLazy           := True;
  FActiveEvents         := True;
  FShowKeyInLabel       := False;
  FColumns              := TColumnCollection.Create(Self);
  FGridWidth            := -1;
  FGridHeight           := -1;
  FGridIsFocus          := False;
  FShowRecordsEmptyText := False;
  FRequired             := False;

  FOldTop               := 0;
  FOrietationWasChanged := False;

  Self.Width            := 200;
  Self.Height           := 24;
  Self.BevelOuter       := bvNone;
  Self.Color            := clBlack;
  Self.BackgroundColor  := clWhite;
  Self.Padding.Left     := 1;
  Self.Padding.Top      := 1;
  Self.Padding.Right    := 1;
  Self.Padding.Bottom   := 1;
  Self.ParentBackground := False;
  Self.TabStop          := False;

  InitSearcPanel;
  InitGrid;
  InitTimer;

  PageSize := 100;

  ShowColumnList := True;

end;

function TEditLazyQuery.DataSetIsActivated: Boolean;
begin
  Result := (Assigned(FDataSet) and FDataSet.Active);
end;

destructor TEditLazyQuery.Destroy;
begin
  if Assigned(FTimer) then
  begin
    FreeAndNil(FTimer);
  end;

  if Assigned(FSearchPanel) then
  begin
    FreeAndNil(FSearchPanel);
  end;

  if Assigned(FColumns) then
  begin
    FreeAndNil(FColumns);
  end;

  inherited;
end;

procedure TEditLazyQuery.DoEnter;
begin
  inherited;

  FGridIsFocus := False;

  if FActiveEvents then
  begin
    FSearchPanel.ShowLabelKey(False);

    if Assigned(FOnEnter) then
    begin
      FOnEnter(Self);
    end;

    FSearchPanel.SetFocusEdit;
	  FSearchPanel.EditSearch.SelStart := Length(Text);

  end;
end;

procedure TEditLazyQuery.DoExit;
begin
  inherited;

  if not (Screen.ActiveControl.ClassType = TcxGridSite) then
  begin

    if (Required) and (IsNull) then
    begin
      FSearchPanel.SetFocusEdit;
      raise Exception.Create('Campo obrigatório');
    end;

    HideGrid;

    if Assigned(FOnExit) then
    begin
      FOnExit(Self);
    end;

    if DataSetIsActivated then
    begin
      if (not FDataSet.IsEmpty) and (Text <> EmptyStr) then
      begin
        if (FLastSearch <> Text) then
        begin
          GetSelectedItem;
        end;
      end
      else
      begin
        Active    := False;
        FKeyValue := Null;
        FSearchPanel.ShowLabelKey(False);
        Active    := True;
      end;
    end;
  end
  else
  begin
    FGridIsFocus := True;
  end;
  //PostMessage(FSearchPanel.EditSearch.Handle, WM_KILLFOCUS, 0, 0);
end;

procedure TEditLazyQuery.DoOnGetRecords(StatusRecord: TStatusRecord);
begin
  DoSearch(Text, False);
end;

procedure TEditLazyQuery.DoOnGridDblClick;
begin
  FActiveEvents := False;
  try
    GetSelectedItem;
  finally
    FActiveEvents := True;
  end;
end;

procedure TEditLazyQuery.DoOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin


  if (Shift = [ssShift]) and (Key = VK_TAB) then
  begin
    PreviousControlFocus;
  end
  else
  if (Shift = [ssAlt]) and (Key = VK_RETURN) then
  begin
    if not PanelResultFormIsShowing then
    begin
      OpenPanelResultForm;
    end
    else
    begin
      MaximizePanelResultForm;
    end;
  end
  else
  if (Key = VK_RETURN) then
  begin
    //Key := 0;

    // It's typing
    if FTimer.Enabled then
    begin
      Search(Text);
    end
    else
    begin
      if GridIsShowed then
      begin
        GetSelectedItem;
      end;

      if FGridIsFocus then
      begin
        FActiveEvents := False;
        try
          FSearchPanel.SetFocusEdit;
        finally
          FActiveEvents := True;
        end;
      end;

      // This method call the Key Tab
      Keybd_event(VK_TAB,0,0,0);
      Key := 0;
    end;
  end
  else
  if (Key = VK_TAB) then
  begin
    if (Text = EmptyStr) or (not (GridIsShowed) and not (FTimer.Enabled)) then
    begin
      NextControlFocus;
    end;
  end
  else
  if (Key = VK_ESCAPE) then
  begin
    HideGrid;
  end
  else
  if (Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT]) then
  begin
    if DataSetIsActivated then
    begin
      if not FDataSet.IsEmpty then
      begin
        if not GridIsShowed then
        begin
          ShowGrid;
        end
        else
        begin
          case Key of
            VK_UP   : FDataSet.Prior;
            VK_DOWN : FDataSet.Next;
            VK_NEXT : FDataSet.Last;
            VK_PRIOR: FDataSet.First;
          end;
        end;
      end;
      Key := 0;
    end
    else
    if (ShowRecordsEmptyText) then
    begin
      if (Key = VK_DOWN) then
      begin
        DoSearch(Text);
        Key := 0;
      end;
    end;
  end;

  if (Key <> 0) then
  begin
    inherited KeyDown(Key, Shift);
  end;

  if Assigned(OnEditKeyDown) then
  begin
    OnEditKeyDown(Self, Key, Shift);
  end;

end;

procedure TEditLazyQuery.DoOnPageButtonClick(Sender: TPageButton);
begin
  if Active then
  begin
    DoSearch(Text, False);
  end;
end;

procedure TEditLazyQuery.DoOnPanelResultExit(Sender: TObject);
begin
  FSearchPanel.SetFocusEdit;
end;

procedure TEditLazyQuery.DoOnPopupClick;
begin
  BuildColumns;
end;

procedure TEditLazyQuery.DoOnPopupItemClick(ItemIndex: Integer; Checked: Boolean);
begin
  FPanelResult.Grid.VisibleColumn(ItemIndex, Checked);
end;

procedure TEditLazyQuery.DoOnTextChange(Text: string);
begin
  if Active then
  begin
    if Assigned(FPanelResult) then
    begin
      FPanelResult.InitRowsCount;
    end;

    FKeyValue := Null;
    FSearchPanel.ShowLabelKey(False);
    FTimeOut  := Now;
    if not (FTimer.Enabled) then
    begin
      FTimer.Enabled := True;
    end;
  end;
end;

procedure TEditLazyQuery.DoOnTextChangeTimer(Sender: TObject);
begin
  if ActiveLazy then
  begin
    if (DateUtils.MilliSecondsBetween(Now, FTimeOut) >= FDelay) then
    begin
      Search(Text);
    end;
  end;
end;

procedure TEditLazyQuery.DoSearch(Text: string; RequireRowsCount: Boolean);
var
  LRecordCount, LEndRowNum: Integer;
begin
  Process(
    procedure
    begin
      if not Assigned(FOnGetRecordCount) then
      begin
        raise Exception.Create('O método OnGetRecordCount deve ser implementado');
      end;

      if (not ShowRecordsEmptyText) and (Text = '') then
      begin
        EmptyDataSet;
      end
      else
      begin

        if RequireRowsCount then
        begin
          FOnGetRecordCount(LRecordCount);
          FPanelResult.UpdateRecords(LRecordCount);
        end;

        if Assigned(FOnSearch) then
        begin
          FOnSearch(FSearchPanel.Text, FPanelResult.StartRowNum, FPanelResult.EndRowNum);
        end;

        FPanelResult.SetDataSet(FDataSet);
      end;

      ShowGrid;
    end
  );
end;

procedure TEditLazyQuery.EmptyDataSet;
begin
  FActive := False;
  try
    FPanelResult.SetDataSet(nil);
  finally
    FActive := True;
  end;
end;

function TEditLazyQuery.GetCharCase: TEditCharCase;
begin
  Result := ecNormal;
  if Assigned(FSearchPanel) then
  begin
    Result := FSearchPanel.EditSearch.CharCase;
  end;
end;

function TEditLazyQuery.GetKeyFieldColor: TColor;
begin
  Result := FSearchPanel.LabelKey.Font.Color;
end;

function TEditLazyQuery.GetKeyLabelPosition: TLabelAlign;
begin
  case FSearchPanel.LabelKey.Align of
    alRight: Result := laRight;
    else Result     := laLeft;
  end;
end;

function TEditLazyQuery.GetLeftParentForm(Control: TControl): Integer;
var
  LControl: TControl;
begin
  LControl := Control;
  Result   := LControl.left;
  while not (LControl.Parent is TForm) do
  begin
    LControl := LControl.Parent;
    Inc(Result, LControl.left);
  end;
end;

function TEditLazyQuery.GetMaxLength: Integer;
begin
  Result := -1;
  if Assigned(FSearchPanel) then
  begin
    Result := FSearchPanel.EditSearch.MaxLength;
  end;
end;

function TEditLazyQuery.GetReadOnly: Boolean;
begin
  Result := False;
  if Assigned(FSearchPanel) then
  begin
    Result := FSearchPanel.EditSearch.ReadOnly;
  end;
end;

procedure TEditLazyQuery.GetSelectedItem;
begin
  if DataSetIsActivated and (not FDataSet.IsEmpty) and not FPanelResult.DataSourceIsEmpty then
  begin
    if not Assigned(FDataSet.Fields.FindField(FKeyFieldName)) then
    begin
      raise Exception.Create('O KeyFieldName ' + FKeyFieldName + ' não existe no DataSet');
    end;

    if not Assigned(FDataSet.Fields.FindField(FDisplayFieldName)) then
    begin
      raise Exception.Create('O DisplayFieldName ' + FDisplayFieldName + ' não existe no DataSet');
    end;

    //if (FKeyValue <> FDataSet.FieldByName(FKeyFieldName).Value) then
    begin
      try
        Active    := False;
        Text      := FDataSet.FieldByName(FDisplayFieldName).AsString;
        FKeyValue := FDataSet.FieldByName(FKeyFieldName).Value;
      finally
        Active := True;
      end;
    end;

    if FShowKeyInLabel then
    begin
      FSearchPanel.SetCaptionLabelKey(KeyValue);
      FSearchPanel.ShowLabelKey(True);
    end;
  end;

  if GridIsShowed then
  begin
    HideGrid;
  end;

end;

function TEditLazyQuery.GetText: string;
begin
  Result := FSearchPanel.Text;
end;

function TEditLazyQuery.GetTextHint: string;
begin
  Result := FSearchPanel.EditSearch.TextHint;
end;

function TEditLazyQuery.GetTopParentForm(Control: TControl): Integer;
var
  LControl: TControl;
begin
  LControl := Control;
  Result   := LControl.Top;
  while not (LControl.Parent is TForm) do
  begin
    LControl := LControl.Parent;
    Inc(Result, LControl.Top);
  end;
end;

function TEditLazyQuery.GridIsShowed: Boolean;
begin
  Result := Assigned(FPanelResult) and (FPanelResult.Visible);
end;

procedure TEditLazyQuery.HideGrid;
begin
  if GridIsShowed then
  begin
    Self.ParentBackground := True;
    Self.ParentBackground := False;
    Self.BringToFront;

    FPanelResult.Visible := False;

    if FOrietationWasChanged then
    begin
      FSearchPanel.Align    := alTop;
      Self.Top              := FOldTop;
    end;

    if PanelResultFormIsShowing then
    begin
      ClosePanelResultForm;
    end;
  end;
end;

procedure TEditLazyQuery.InitGrid;
begin
  if not Assigned(FPanelResult) then
  begin
    FPanelResult := TPanelResult.Create(Self);

    FPanelResult.DoubleBuffered   := True;
    FPanelResult.ParentDoubleBuffered := False;

    FPanelResult.SetSubComponent(False);

    FPanelResult.Visible            := False;
    FPanelResult.Margins.Left       := 1;
    FPanelResult.Margins.Top        := 0;
    FPanelResult.Margins.Right      := 1;
    FPanelResult.Margins.Bottom     := 1;
    FPanelResult.BevelInner         := bvNone;
    FPanelResult.BevelOuter         := bvNone;
    FPanelResult.TabStop            := True;
    FPanelResult.Grid.OnGridKeyDown := DoOnKeyDown;
    FPanelResult.Grid.OnDblClick    := DoOnGridDblClick;
    FPanelResult.OnGetRecords       := DoOnGetRecords;
    FPanelResult.OnPageButtonClick  := DoOnPageButtonClick;
    FPanelResult.OnExit             := DoOnPanelResultExit;
  end;
  FPanelResult.PageSize := FPageSize;
  FPanelResult.Height   := C_GRID_HEIGHT;
  //FPanelResult.Width    := Self.Width;

  if not (csDesigning in ComponentState) then
  begin
    FPanelResult.Parent := GetInnermostParentForm(TWinControl(Owner));
  end;

end;

procedure TEditLazyQuery.InitSearcPanel;
begin
  FSearchPanel                  := TSearchPanel.Create(Self);
  FSearchPanel.Parent           := Self;
  FSearchPanel.SetSubComponent(False);
  FSearchPanel.DoubleBuffered   := True;
  FSearchPanel.ParentDoubleBuffered := False;
  FSearchPanel.Align            := alTop;
  FSearchPanel.OnTextChange     := DoOnTextChange;
  FSearchPanel.OnEditKeyDown    := DoOnKeyDown;
  FSearchPanel.OnPopupItemClick := DoOnPopupItemClick;
  FSearchPanel.OnPopupClick     := DoOnPopupClick;
end;

procedure TEditLazyQuery.InitShapeHide;
begin
  FShapeHide             := TShape.Create(Self);
  FShapeHide.Parent      := Self.Parent;
  FShapeHide.Align       := Self.Align;
  FShapeHide.Left        := Self.Left;
  FShapeHide.Top         := Self.Top;
  FShapeHide.Width       := Self.Width;
  FShapeHide.Height      := Self.Height;
  FShapeHide.Brush.Style := bsBDiagonal;
  FShapeHide.Pen.Style   := psDot;
end;

procedure TEditLazyQuery.InitTimer;
begin
  FTimer          := TTimer.Create(Self);
  FTimer.Enabled  := False;
  FTimer.Interval := FDelay;
  FTimer.OnTimer  := DoOnTextChangeTimer;
  FTimer.SetSubComponent(False);
end;

function TEditLazyQuery.IsNull: Boolean;
begin
  Result := VarIsNull(FKeyValue) or VarIsEmpty(FKeyValue);
end;

procedure TEditLazyQuery.MaximizePanelResultForm;
var
  i: Integer;
begin
  if PanelResultFormIsShowing then
  begin
    FPanelResult.Grid.ShowAllColumns;
    frmPanelResult.WindowState := wsMaximized;
  end;
end;

procedure TEditLazyQuery.NextControlFocus;
var
  MyForm: TCustomForm;
begin
  if FGridIsFocus then
  begin
    FActiveEvents := False;
    try
      FSearchPanel.SetFocusEdit;
    finally
      FActiveEvents := True;
    end;
  end;

  // Go to the next control
  MyForm := GetParentForm(Self);
  if not (MyForm = nil) then
  begin
    SendMessage(MyForm.Handle, WM_NEXTDLGCTL, 0, 0);
    Application.ProcessMessages;
  end;
end;

procedure TEditLazyQuery.OpenPanelResultForm;
var
  LTop   : Integer;
  LLeft  : Integer;
  LHeight: Integer;
  LWidht, LTabOrder: Integer;
  LAlign, LPanelResultAlign : TAlign;
  LParent, LPanelResultParent: TWinControl;
  LAnchors: TAnchors;
begin
  frmPanelResult := TfrmPanelResult.Create(nil);
  try
    FPanelResult.Visible := True;

    // Save component's values
    LTop               := Self.Top;
    LLeft              := Self.Left;
    LHeight            := Self.Height;
    LWidht             := Self.Width;
    LAlign             := Self.Align;
    LParent            := Self.Parent;
    LAnchors           := Self.Anchors;
    LTabOrder          := Self.TabOrder;
    LPanelResultParent := FPanelResult.Parent;
    LPanelResultAlign  := FPanelResult.Align;

    InitShapeHide;

    // Change parent and controls of component
    Self.Parent             := frmPanelResult;
    Self.Align              := alTop;
    Self.Height             := 24;

    FPanelResult.Parent     := frmPanelResult;
    FPanelResult.Align      := alClient;

    frmPanelResult.Width    := 700;
    frmPanelResult.Height   := 700;
    frmPanelResult.Position := poScreenCenter;
    frmPanelResult.ShowModal;
  finally
    Self.Parent         := LParent;
    FPanelResult.Parent := LPanelResultParent;

    Self.Align          := LAlign;
    FPanelResult.Align  := LPanelResultAlign;

    Self.Top      := LTop;
    Self.Left     := LLeft;
    Self.Height   := LHeight;
    Self.Width    := LWidht;
    Self.Anchors  := LAnchors;
    Self.TabOrder := LTabOrder;

    FreeAndNil(frmPanelResult);
    FreeAndNil(FShapeHide);
    InitGrid;
    HideGrid;

    Self.SetFocus;
  end;
end;

procedure TEditLazyQuery.Paint;
begin
  inherited;
  if not PanelResultFormIsShowing then
  begin
    CalcOrientation;
  end;
end;

function TEditLazyQuery.PanelResultFormIsShowing: Boolean;
begin
  Result := Assigned(frmPanelResult);
end;

procedure TEditLazyQuery.PreviousControlFocus;
var
  MyForm: TCustomForm;
begin
  // Go to the previous control
  MyForm := GetParentForm(Self);
  if not (MyForm = nil) then
  begin
    SendMessage(MyForm.Handle, WM_NEXTDLGCTL, 1, 0);
  end;
end;

procedure TEditLazyQuery.Process(Method: TProc);
begin
  Screen.Cursor      := crSQLWait;
  Self.Color         := clRed;
  FPanelResult.Color := Self.Color;
  FSearchPanel.ShowDisplaySearching('Pesquisando por ' + QuotedStr(Text));
  FPanelResult.VisibleControls(False);

  Application.ProcessMessages;
  FActive := False;
  try
    Method();
  finally
    FSearchPanel.HideDisplaySearching;
    Self.Color         := clBlack;
    FPanelResult.Color := Self.Color;
    Screen.Cursor      := crDefault;
    FPanelResult.VisibleControls(True);
    FActive       := True;
  end;
end;

procedure TEditLazyQuery.Search(Text: string);
begin
  FTimer.Enabled := False;

  if (FLastSearch <> Text) then
  begin
    FLastSearch := Text;
    DoSearch(Text);
  end
  else
  if (Text <> EmptyStr) then
  begin
    ShowGrid;
  end;
end;

procedure TEditLazyQuery.SetActive(const Value: Boolean);
begin
  FActive        := Value;
  FTimer.Enabled := False;
end;

procedure TEditLazyQuery.SetActiveLazy(const Value: Boolean);
begin
  FActiveLazy    := Value;
  FTimer.Enabled := Value;
end;

procedure TEditLazyQuery.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  if Assigned(FSearchPanel) then
  begin
    FSearchPanel.SetColor(FBackgroundColor);
  end;
end;

procedure TEditLazyQuery.SetCharCase(const Value: TEditCharCase);
begin
  if Assigned(FSearchPanel) then
  begin
    FSearchPanel.EditSearch.CharCase := Value;
  end;
end;

procedure TEditLazyQuery.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  if Assigned(FPanelResult) then
  begin
    FPanelResult.SetDataSet(FDataSet);
  end;
end;

procedure TEditLazyQuery.SetDelay(const Value: Integer);
begin
  FDelay          := Value;
  FTimer.Enabled  := False;
  FTimer.Interval := FDelay;
end;

procedure TEditLazyQuery.SetKeyFieldColor(const Value: TColor);
begin
  FSearchPanel.LabelKey.Font.Color := Value;
end;

procedure TEditLazyQuery.SetKeyLabelPosition(const Value: TLabelAlign);
begin
  case Value of
    laLeft : FSearchPanel.LabelKey.Align := alLeft;
    laRight: FSearchPanel.LabelKey.Align := alRight;
  end;
end;

procedure TEditLazyQuery.SetKeyValue(const Value: OleVariant);
begin
  FKeyValue := Value;
  if Assigned(FOnSearchByKeyValue) then
  begin
    Process(
      procedure
      begin
        FOnSearchByKeyValue(FKeyValue);
        FPanelResult.SetDataSet(FDataSet);
        FPanelResult.UpdateRecords(1);
        FLastSearch := FKeyValue;
        InitGrid;
        BuildColumns;
        GetSelectedItem;
      end
    );
  end;
end;

procedure TEditLazyQuery.SetMaxLength(const Value: Integer);
begin
  if Assigned(FSearchPanel) then
  begin
    FSearchPanel.EditSearch.MaxLength := Value;
  end;
end;

procedure TEditLazyQuery.SetPageSize(const Value: Integer);
begin
  FPageSize := Value;
  if Assigned(FPanelResult) then
  begin
    FPanelResult.PageSize := FPageSize;
  end;
end;

procedure TEditLazyQuery.SetReadOnly(const Value: Boolean);
begin
  if Assigned(FSearchPanel) then
  begin
    FSearchPanel.EditSearch.ReadOnly := Value;
  end;
end;

procedure TEditLazyQuery.SetShowColumnList(const Value: Boolean);
begin
  FShowColumnList := Value;
  FSearchPanel.ShowColumnList := FShowColumnList;
end;

procedure TEditLazyQuery.SetText(const Value: string);
begin
  FSearchPanel.Text := Value;
end;

procedure TEditLazyQuery.SetTextHint(const Value: string);
begin
  FSearchPanel.EditSearch.TextHint := Value;
end;

procedure TEditLazyQuery.ShowGrid;
begin
  // If the Control lost focus, set focus on EditSearch
  if (Screen.ActiveControl <> FSearchPanel.EditSearch) then
  begin
    if FSearchPanel.EditSearch.CanFocus then
    begin
      try
        FSearchPanel.EditSearch.SetFocus;
        FSearchPanel.EditSearch.SelStart := Length(Text);
      except
      end;
    end;
  end;

  if not GridIsShowed then
  begin
    InitGrid;
    FPanelResult.Visible := True;
    FPanelResult.BringToFront;
  end;

  BuildColumns;

end;

end.
