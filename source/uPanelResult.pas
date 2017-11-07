unit uPanelResult;

interface

uses
  ExtCtrls, Classes, uGridResult, cxButtons, DB, Forms, pngimage, StdCtrls,
  Controls, Graphics, SysUtils, Windows, ComCtrls, Generics.Collections;

type
  TStatusRecord = (srFirst, srLast);
  TOnGetRecords = procedure(StatusRecord: TStatusRecord) of object;

  TPageButton = class(TPanel)
  private
    FChecked: Boolean;

    procedure SetChecked(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;

    function GetPageNumber: Integer;

    property Checked: Boolean read FChecked write SetChecked;
  end;

  TOnPageButtonClick = procedure(Sender: TPageButton) of object;

  TPagination = class(TPanel)
  private
    FRecordCount      : Integer;
    FPagesCount       : Integer;
    FButtonsList      : TList<TPageButton>;
    FPageSize         : Integer;
    FPrior            : TPageButton;
    FNext             : TPageButton;
    FLastPage         : Integer;
    FFirstPage        : Integer;
    FPageCurrent      : Integer;
    FOnPageButtonClick: TOnPageButtonClick;

    procedure DoOnPageButtonClick(Sender: TObject);
    procedure DoOnPriorButtonClick(Sender: TObject);
    procedure DoOnNextButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BuildPagination(Pages: Integer);
    procedure InitRowsCount;
    procedure NextPage;

    property RecordCount: Integer read FRecordCount write FRecordCount;
    property PageSize: Integer read FPageSize write FPageSize;
    property PagesCount: Integer read FPagesCount;
    property PageCurrent: Integer read FPageCurrent;
    property OnPageButtonClick: TOnPageButtonClick read FOnPageButtonClick write FOnPageButtonClick;
  end;

  TPanelResult = class(TPanel)
  private
    FContainer        : TPanel;
    FGrid             : TGrid;
    FButton           : TcxButton;
    FDataSource       : TDataSource;
    FOnGetRecords     : TOnGetRecords;
    FLabelCount       : TLabel;
    FStartRowNum      : Integer;
    FEndRowNum        : Integer;
    FPageNumber       : Integer;
    FRecordCount      : Integer;
    FUpDown           : TUpDown;
    FPanelPageNumber  : TPanel;
    FPanelPagination  : TPagination;
    FOnPageButtonClick: TOnPageButtonClick;
    FRecNo            : Integer;
    FPageSize         : Integer;

    procedure InitContainer;
    procedure InitGrid;
    procedure InitPagination;
    procedure InitDataSource;

    procedure DoOnDSDataChange(Sender: TObject; Field: TField);
    procedure DoOnUpdateRecordCount(CurrentRecord: Integer);
    procedure DoOnPageButtonClick(Sender: TPageButton);
    procedure SetPageSize(const Value: Integer);
    function GetEndRowNum: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDataSet(DataSet: TDataSet);
    function DataSourceIsEmpty: Boolean;
    procedure InitRowsCount;
    procedure UpdateRecords(const ARecordCount: Integer);
    procedure VisibleControls(Value: Boolean);

    property Grid: TGrid read FGrid;
    property StartRowNum: Integer read FStartRowNum;
    property EndRowNum: Integer read GetEndRowNum;
    property RecordCount: Integer read FRecordCount;
    property RecNo: Integer read FRecNo;
    property PageSize: Integer read FPageSize write SetPageSize;
    property OnGetRecords: TOnGetRecords read FOnGetRecords write FOnGetRecords;
    property OnPageButtonClick: TOnPageButtonClick read FOnPageButtonClick write FOnPageButtonClick;
  end;


implementation

uses
  cxControls;


const
  C_MAX_VISIBLE_PAGES = 5;

{$R ResEditLateQuery.RES}

{ TPanelResult }

constructor TPanelResult.Create(AOwner: TComponent);
begin
  inherited;
  Self.BevelOuter       := bvNone;
  Self.Color            := clBlack;
  Self.ParentBackground := False;
  Self.Padding.Left     := 1;
  Self.Padding.Top      := 1;
  Self.Padding.Right    := 1;
  Self.Padding.Bottom   := 1;

  InitRowsCount;
  InitContainer;
  InitGrid;
  InitPagination;
  InitDataSource;

  FContainer.Caption    := 'CARREGANDO';
  FContainer.Font.Style := [fsBold];
  FContainer.Font.Size  := 6;
end;

function TPanelResult.DataSourceIsEmpty: Boolean;
begin
  Result := not Assigned(FDataSource) or not Assigned(FDataSource.DataSet);
end;

destructor TPanelResult.Destroy;
begin
  if Assigned(FDataSource) then
  begin
    FreeAndNil(FDataSource);
  end;

  if Assigned(FButton) then
  begin
    FreeAndNil(FButton);
  end;

  if Assigned(FGrid) then
  begin
    FreeAndNil(FGrid);
  end;

  if Assigned(FLabelCount) then
  begin
    FreeAndNil(FLabelCount);
  end;

  if Assigned(FUpDown) then
  begin
    FreeAndNil(FUpDown);
  end;

  if Assigned(FPanelPageNumber) then
  begin
    FreeAndNil(FPanelPageNumber);
  end;

  if Assigned(FPanelPagination) then
  begin
    FreeAndNil(FPanelPagination);
  end;

  inherited;
end;

procedure TPanelResult.DoOnDSDataChange(Sender: TObject; Field: TField);
begin
  if not FDataSource.DataSet.IsEmpty then
  begin
    if FDataSource.DataSet.Eof then
    begin
      if (FRecNo < FRecordCount) then
      begin
        FDataSource.DataSet.DisableControls;
        try
          FDataSource.DataSet.Prior;
          FPanelPagination.NextPage;
          if Assigned(FOnGetRecords) then
          begin
            FOnGetRecords(srLast);
          end;
        finally
          FDataSource.DataSet.EnableControls;
        end;
      end;
    end;
  end
  else
  begin
    InitRowsCount;
  end;
  FGrid.UpdateRowCount(StartRowNum, EndRowNum, RecordCount);
end;

procedure TPanelResult.DoOnPageButtonClick(Sender: TPageButton);
begin
  FEndRowNum   := (FPanelPagination.PageCurrent * FPageSize);
  FStartRowNum := FEndRowNum - (FPageSize - 1);

  if Assigned(FOnPageButtonClick) then
  begin
    FOnPageButtonClick(Sender);
  end;
end;

procedure TPanelResult.DoOnUpdateRecordCount(CurrentRecord: Integer);
begin
  FRecNo := ((FPanelPagination.PageCurrent - 1) * FPanelPagination.PageSize) + (CurrentRecord + 1);

  FLabelCount.Visible := False;
  try
    if FRecNo > RecordCount then
    begin
      FLabelCount.Caption := 'Calculando...';
    end
    else
    begin
      FLabelCount.Caption := IntToStr(FRecNo) + ' de ' + IntToStr(RecordCount);
    end;
  finally
    FLabelCount.Visible := True;
  end;
end;

function TPanelResult.GetEndRowNum: Integer;
begin
  if (FEndRowNum <= 0) then
  begin
    FEndRowNum := FPageSize;
  end;
  Result := FEndRowNum;
end;

procedure TPanelResult.InitPagination;
var
  pnBottom: TPanel;
begin
  pnBottom                  := TPanel.Create(Self);
  pnBottom.Parent           := FContainer;
  pnBottom.SetSubComponent(False);
  pnBottom.Height           := 20;
  pnBottom.Align            := alBottom;
  pnBottom.BevelOuter       := bvNone;
  pnBottom.Color            := clWhite;
  pnBottom.ParentBackground := False;
  pnBottom.TabOrder         := 0;
  pnBottom.ParentFont       := False;

  FPanelPagination                   := TPagination.Create(Self);
  FPanelPagination.Parent            := pnBottom;
  FPanelPagination.SetSubComponent(False);
  FPanelPagination.Align             := alLeft;
  FPanelPagination.BevelOuter        := bvNone;
  FPanelPagination.TabOrder          := 0;
  FPanelPagination.AutoSize          := True;
  //FPanelPagination.PageSize          := 100;
  FPanelPagination.OnPageButtonClick := DoOnPageButtonClick;

  FLabelCount                  := TLabel.Create(Self);
  FLabelCount.Parent           := pnBottom;
  FLabelCount.SetSubComponent(False);
  FLabelCount.AlignWithMargins := True;
  FLabelCount.Margins.Left     := 0;
  FLabelCount.Margins.Top      := 0;
  FLabelCount.Margins.Bottom   := 0;
  FLabelCount.Align            := alRight;
  FLabelCount.Caption          := '0 de 0';
  FLabelCount.Font.Style       := [fsBold];
  FLabelCount.Font.Size        := 6;
  FLabelCount.ParentFont       := False;
  FLabelCount.Layout           := tlCenter;
end;

procedure TPanelResult.InitContainer;
begin
  FContainer                  := TPanel.Create(Self);
  FContainer.Parent           := Self;
  FContainer.SetSubComponent(False);
  FContainer.Align            := alClient;
  FContainer.BevelOuter       := bvNone;
  FContainer.Color            := clWhite;
  FContainer.ParentBackground := False;
  FContainer.TabStop          := False;
end;

procedure TPanelResult.InitDataSource;
begin
  FDataSource := TDataSource.Create(Self);
  FDataSource.SetSubComponent(False);
  FDataSource.OnDataChange := DoOnDSDataChange;
end;

procedure TPanelResult.InitGrid;
begin
  FGrid                     := TGrid.Create(Self);
  FGrid.Parent              := FContainer;
  FGrid.SetSubComponent(False);
  FGrid.Align               := alClient;
  FGrid.TabStop             := False;
  FGrid.ParentFont          := False;
  FGrid.BorderStyle         := cxcbsNone;
  FGrid.OnUpdateRecordCount := DoOnUpdateRecordCount;
end;

procedure TPanelResult.InitRowsCount;
begin
  FRecordCount        := 0;
  FStartRowNum        := 1;
  FEndRowNum          := FPageSize;
  FPageNumber         := 1;
  FLabelCount.Caption := '0 de 0';
  if Assigned(FPanelPagination) then
  begin
    FPanelPagination.InitRowsCount;
  end;
end;


procedure TPanelResult.SetDataSet(DataSet: TDataSet);
begin
  FDataSource.DataSet := DataSet;
  FGrid.SetDataSource(FDataSource);

  if not Assigned(DataSet) then
  begin
    UpdateRecords(0);
  end;
end;

procedure TPanelResult.SetPageSize(const Value: Integer);
begin
  FPageSize  := Value;
  if Assigned(FPanelPagination) then
  begin
    FPanelPagination.PageSize := FPageSize;
  end;
end;

procedure TPanelResult.UpdateRecords(const ARecordCount: Integer);
begin
  FRecordCount                 := ARecordCount;
  FPanelPagination.RecordCount := FRecordCount;
  FPanelPagination.BuildPagination(C_MAX_VISIBLE_PAGES);
end;

procedure TPanelResult.VisibleControls(Value: Boolean);
begin
  FGrid.Visible       := Value;
  FLabelCount.Visible := Value;
end;

{ TPageButton }

constructor TPageButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  AlignWithMargins := True;
  Width := 20;
  Margins.Left := 1;
  Margins.Top := 1;
  Margins.Right := 1;
  Margins.Bottom := 1;
  Align := alLeft;
  BevelOuter := bvNone;
  Caption := '1';
  Font.Size := 6;
  ParentBackground := False;
  ParentFont := False;
  TabStop := False;
  TabOrder := 0;
  Cursor := crHandPoint;

  SetChecked(False);
end;

function TPageButton.GetPageNumber: Integer;
begin
  Result := StrToIntDef(Caption, 0);
end;

procedure TPageButton.SetChecked(const Value: Boolean);
begin
  FChecked := Value;

  if FChecked then
  begin
    Color      := $0033C36A;
    Font.Color := clWhite;
    Font.Style := [fsBold];
  end
  else
  begin
    Color      := clWhite;
    Font.Color := clBlack;
    Font.Style := [fsBold, fsUnderline];
  end;
end;

{ TPagination }

procedure TPagination.BuildPagination(Pages: Integer);
var
  PageButton: TPageButton;
  i, ItemIndex: Integer;
begin
  Self.Visible := False;
  Application.ProcessMessages;

  FPagesCount := RecordCount div PageSize;

  if (RecordCount mod PageSize) > 0 then
  begin
    FPagesCount := FPagesCount + 1;
  end;

  if (RecordCount > 0) and (FPagesCount > 1) then
  begin
    try
      ItemIndex := 0;

      if (Pages > 0) then
      begin
        FFirstPage := FLastPage + 1;
        FLastPage  := FLastPage + Pages;
      end
      else
      begin
        FFirstPage := FFirstPage + Pages;
        FLastPage  := FFirstPage + Abs(Pages) - 1;
      end;

      for PageButton in FButtonsList do
      begin
        PageButton.Caption := '';
        PageButton.Checked := False;
      end;

      for i := FFirstPage to FLastPage do
      begin
        if (i > FPagesCount) then
        begin
          Break;
        end
        else
        begin
          FButtonsList.Items[ItemIndex].Caption := IntToStr(i);

          if (i = FFirstPage) then
          begin
            DoOnPageButtonClick(FButtonsList.Items[ItemIndex]);
          end;
        end;
        ItemIndex := ItemIndex + 1;
      end;

      if FLastPage > FPagesCount then
      begin
        FLastPage := FPagesCount;
      end;
    finally
      Self.Visible := True;
      Application.ProcessMessages;
    end;
  end;
end;

constructor TPagination.Create(AOwner: TComponent);
var
  i: Integer;
  PageButton: TPageButton;
  ImgPrior, ImgNext: TImage;
  Png: TPngImage;
begin
  inherited;
  Align        := alLeft;
  BevelOuter   := bvNone;
  TabOrder     := 0;
  AutoSize     := True;
  TabStop      := False;

  FButtonsList := TList<TPageButton>.Create;
  InitRowsCount;

  Self.Visible := False;
  try
    // init
    if not Assigned(FPrior) then
    begin
      FPrior         := TPageButton.Create(Self);
      FPrior.Parent  := Self;
      FPrior.Caption := '';

      ImgPrior := TImage.Create(Self);
      ImgPrior.Parent := FPrior;
      ImgPrior.Align := alClient;
      ImgPrior.AutoSize := True;
      ImgPrior.Center := True;
      ImgPrior.OnClick := DoOnPriorButtonClick;

      Png := TPngImage.Create;
      try
        Png.LoadFromResourceName(HInstance, 'LEFT');
        ImgPrior.Picture.Graphic := Png; // Image1: TImage on the form
      finally
        Png.Free;
      end;
    end;

    for i := 1 to C_MAX_VISIBLE_PAGES do
    begin
      PageButton         := TPageButton.Create(Self);
      PageButton.Parent  := Self;
      PageButton.Caption := IntToStr(i);
      PageButton.OnClick := DoOnPageButtonClick;

      if i = 1 then
      begin
        PageButton.Checked := True;
      end;

      FButtonsList.Add(PageButton);
    end;

    if not Assigned(FNext) then
    begin
      FNext         := TPageButton.Create(Self);
      FNext.Parent  := Self;
      FNext.Caption := '';

      ImgNext := TImage.Create(Self);
      ImgNext.Parent := FNext;
      ImgNext.Align := alClient;
      ImgNext.AutoSize := True;
      ImgNext.Center := True;
      ImgNext.OnClick := DoOnNextButtonClick;

      Png := TPngImage.Create;
      try
        Png.LoadFromResourceName(HInstance, 'RIGHT');
        ImgNext.Picture.Graphic := Png; // Image1: TImage on the form
      finally
        Png.Free;
      end;
    end;
  finally
    Self.Visible := True;
  end;
end;

destructor TPagination.Destroy;
begin
  if Assigned(FButtonsList) then
  begin
    FreeAndNil(FButtonsList);
  end;

  if Assigned(FPrior) then
  begin
    FreeAndNil(FPrior);
  end;

  if Assigned(FNext) then
  begin
    FreeAndNil(FNext);
  end;

  inherited;
end;

procedure TPagination.DoOnNextButtonClick(Sender: TObject);
begin
  if (FLastPage < FPagesCount) and (FPageCurrent < FPagesCount) then
  begin
    BuildPagination(C_MAX_VISIBLE_PAGES);
  end;
end;

procedure TPagination.DoOnPageButtonClick(Sender: TObject);
var
  PageButton: TPageButton;
begin
  if (not (Sender as TPageButton).Checked) and ((Sender as TPageButton).GetPageNumber > 0) then
  begin
    for PageButton in FButtonsList do
    begin
      PageButton.Checked := (PageButton = Sender);

      if PageButton.Checked then
      begin
        FPageCurrent := StrToInt(PageButton.Caption);
      end;

      Application.ProcessMessages;
    end;

    if Assigned(FOnPageButtonClick) then
    begin
      FOnPageButtonClick(TPageButton(Sender));
    end;
  end;
end;

procedure TPagination.DoOnPriorButtonClick(Sender: TObject);
begin
  if (FFirstPage > 1) and (FPageCurrent > 1) then
  begin
    BuildPagination(C_MAX_VISIBLE_PAGES*-1);
  end;
end;

procedure TPagination.InitRowsCount;
begin
  FPagesCount  := 0;
  FFirstPage   := 0;
  FLastPage    := 0;
  FPageCurrent := 1;
end;

procedure TPagination.NextPage;
var
  PageButton: TPageButton;
  i: Integer;
begin
  for i := 0 to FButtonsList.Count - 1 do
  begin
    PageButton := FButtonsList.Items[i];
    if PageButton.Checked then
    begin
      // Is Last Record?
      if ((i + 1) = FButtonsList.Count) then
      begin
        BuildPagination(C_MAX_VISIBLE_PAGES);
      end
      else
      begin
        // Get Next Page
        PageButton := FButtonsList.Items[i+1];
        DoOnPageButtonClick(PageButton);
      end;
      Break;
    end;
  end;
end;

end.
