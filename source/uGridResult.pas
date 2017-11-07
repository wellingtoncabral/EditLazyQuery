unit uGridResult;

interface

uses
  cxControls, cxGridCustomTableView, cxGridLevel, cxGraphics, cxGrid,
  cxGridDBTableView, Classes, Graphics, Controls, StdCtrls, DB, cxStyles,
  uEvents, cxCustomData;

type
  TOnDblClick = procedure of object;
  TOnUpdateRecordCount = procedure(CurrentRecord: Integer) of object;

  TGrid = class(TcxGrid)
  private
    FTableView    : TcxGridDBTableView;
    FGridLevel    : TcxGridLevel;
    FStyleRepo    : TcxStyleRepository;
    FStyleHeader  : TcxStyle;
    FStyleInactive: TcxStyle;
    FOnGridKeyDown: TOnKeyDown;
    FOnDblClick   : TOnDblClick;
    FRowNumCount: Integer;
    FStartRowNum: Integer;
    FEndRowNum: Integer;
    FOnUpdateRecordCount: TOnUpdateRecordCount;

    procedure InitTableView;
    procedure InitGridLevel;
    procedure InitStyleRepo;
    procedure InitStyleHeader;
    procedure InitStyleInactive;

    procedure DoOnTableViewKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure DoOnTableViewDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure DoOnTableViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDataSource(Datasource: TDataSource);
    procedure AddColumn(Caption, FieldName: string; Width: Integer; Visible: Boolean);
    procedure VisibleColumn(ColIndex: Integer; Value: Boolean);
    procedure UpdateRowCount(AStartRowNum, AEndRowNum, ARowNumCount: Integer);
    procedure ShowAllColumns;

    property OnGridKeyDown: TOnKeyDown read FOnGridKeyDown write FOnGridKeyDown;
    property OnDblClick: TOnDblClick read FOnDblClick write FOnDblClick;
    property OnUpdateRecordCount: TOnUpdateRecordCount read FOnUpdateRecordCount write FOnUpdateRecordCount;
    property StartRowNum: Integer read FStartRowNum write FStartRowNum;
    property EndRowNum: Integer read FEndRowNum write FEndRowNum;
    property RowNumCount: Integer read FRowNumCount write FRowNumCount;
  end;

implementation

uses
  SysUtils;

{ TGrid }

procedure TGrid.AddColumn(Caption, FieldName: string; Width: Integer; Visible: Boolean);
var
  Col: TcxGridDBColumn;
begin
  Col                       := FTableView.CreateColumn;
  Col.Width                 := Width;
  Col.DataBinding.FieldName := FieldName;
  Col.Caption               := Caption;
  Col.Visible               := Visible;
end;

constructor TGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.TabStop := False;
  FStartRowNum := 0;
  FEndRowNum   := 0;
  FRowNumCount := 0;

  if (csDesigning in ComponentState) then
  begin
    Self.Height := 0;
    Self.Width  := 0;
  end;

  InitStyleRepo;
  InitStyleHeader;
  InitStyleInactive;
  InitTableView;
end;

destructor TGrid.Destroy;
begin

  if Assigned(FStyleHeader) then
  begin
    FreeAndNil(FStyleHeader);
  end;

  if Assigned(FStyleInactive) then
  begin
    FreeAndNil(FStyleInactive);
  end;

  if Assigned(FStyleRepo) then
  begin
    FreeAndNil(FStyleRepo);
  end;

  if Assigned(FGridLevel) then
  begin
    FreeAndNil(FGridLevel);
  end;

  if Assigned(FTableView) then
  begin
    FreeAndNil(FTableView);
  end;

  inherited;
end;

procedure TGrid.DoOnTableViewDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  if Assigned(FOnDblClick) then
  begin
    FOnDblClick();
  end;
end;

procedure TGrid.DoOnTableViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  if Assigned(FOnUpdateRecordCount) then
  begin
    FOnUpdateRecordCount(Sender.Controller.FocusedRecordIndex);
  end;
end;

procedure TGrid.DoOnTableViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FOnGridKeyDown) then
  begin
    FOnGridKeyDown(Self, Key, Shift);
  end;
end;

procedure TGrid.InitGridLevel;
begin
  FGridLevel          := Self.Levels.Add;
  FGridLevel.GridView := FTableView;
  FGridLevel.SetSubComponent(False);
end;

procedure TGrid.InitStyleHeader;
begin
  FStyleHeader                := TcxStyle.Create(FStyleRepo);
  FStyleHeader.SetSubComponent(False);
  FStyleHeader.AssignedValues := [svColor, svFont];
  FStyleHeader.Color          := clWhite;
  FStyleHeader.TextColor      := clBlack;
  FStyleHeader.Font.Style     := [fsBold];
  FStyleHeader.Font.Size      := 7;
end;

procedure TGrid.InitStyleInactive;
begin
  FStyleInactive                := TcxStyle.Create(FStyleRepo);
  FStyleInactive.SetSubComponent(False);
  FStyleInactive.AssignedValues := [svTextColor, svColor];
  FStyleInactive.Color          := $00EBEBEB;
  FStyleInactive.TextColor      := clBlack;
end;

procedure TGrid.InitStyleRepo;
begin
  FStyleRepo := TcxStyleRepository.Create(Self);
  FStyleRepo.SetSubComponent(False);
end;

procedure TGrid.InitTableView;
begin
  FTableView := TcxGridDBTableView(Self.CreateView(TcxGridDBTableView));
  FTableView.SetSubComponent(False);
  FTableView.NavigatorButtons.ConfirmDelete := False;
  FTableView.FilterBox.Visible := fvNever;

  //FTableView.DataController.DataSource = DataSource1
  FTableView.OptionsBehavior.CellHints := True;
  FTableView.OptionsBehavior.ColumnHeaderHints := False;

  FTableView.OptionsCustomize.ColumnFiltering := False;
  FTableView.OptionsCustomize.ColumnGrouping := False;
  FTableView.OptionsCustomize.ColumnMoving := False;
  FTableView.OptionsCustomize.ColumnSorting := True;

  FTableView.OptionsData.Deleting := False;
  FTableView.OptionsData.Editing := False;
  FTableView.OptionsData.Inserting := False;

  FTableView.OptionsSelection.CellSelect := False;
  FTableView.OptionsSelection.UnselectFocusedRecordOnExit := False;

  FTableView.OptionsView.ScrollBars := ssVertical;
  FTableView.OptionsView.ColumnAutoWidth := True;
  FTableView.OptionsView.GridLineColor := clWhite;
  FTableView.OptionsView.GridLines := glNone;
  FTableView.OptionsView.GroupByBox := False;
  FTableView.OptionsView.NoDataToDisplayInfoText := '<Nenhum registro>';
  //FTableView.OptionsView.Footer := True;

  FTableView.Styles.Inactive := FStyleInactive;
  FTableView.Styles.Header   := FStyleHeader;
  FTableView.Styles.Selection:= FStyleInactive;

  FTableView.OnKeyDown      := DoOnTableViewKeyDown;
  FTableView.OnCellDblClick := DoOnTableViewDblClick;
  FTableView.OnFocusedRecordChanged := DoOnTableViewFocusedRecordChanged;

  InitGridLevel;
end;

procedure TGrid.SetDataSource(Datasource: TDataSource);
begin
  FTableView.DataController.DataSource := DataSource;
end;

procedure TGrid.ShowAllColumns;
var
  i: Integer;
begin
  for i := 0 to FTableView.ColumnCount - 1 do
  begin
    FTableView.Columns[i].Visible := True;
  end;
end;

procedure TGrid.UpdateRowCount(AStartRowNum, AEndRowNum, ARowNumCount: Integer);
begin
  FStartRowNum := AStartRowNum;
  FEndRowNum   := AEndRowNum;
  FRowNumCount := ARowNumCount;
end;

procedure TGrid.VisibleColumn(ColIndex: Integer; Value: Boolean);
begin
  FTableView.Columns[ColIndex].Visible := Value;
end;

end.
