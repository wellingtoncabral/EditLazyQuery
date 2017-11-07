unit uColumnItem;

interface

uses
  Classes;

type
  TColumnItem = class(TCollectionItem)
  private
    FFieldName : string;
    FCaption   : string;
    FPercentage: Double;
    FVisible   : Boolean;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldName: string read FFieldName write FFieldName;
    property Caption: string read FCaption write FCaption;
    property Percentage: Double read FPercentage write FPercentage;
    property Visible: Boolean read FVisible write FVisible;
  end;

implementation

uses
  SysUtils;

{ TColumnItem }

procedure TColumnItem.Assign(Source: TPersistent);
begin
  if Source is TColumnItem then
  begin
    FieldName  := TColumnItem(Source).FieldName;
    Caption    := TColumnItem(Source).Caption;
    Percentage := TColumnItem(Source).Percentage;
    Visible    := TColumnItem(Source).Visible;
  end
  else
  begin
    inherited; //raises an exception
  end;
end;

constructor TColumnItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
end;

function TColumnItem.GetDisplayName: string;
begin
  Result := Caption  + ' - ' + FieldName + ' (' + FloatToStr(Percentage) + '%)';
end;

end.
