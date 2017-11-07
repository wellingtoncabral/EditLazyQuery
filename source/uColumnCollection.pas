unit uColumnCollection;

interface

uses
  Classes, uColumnItem;

type
  TColumnCollection = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TColumnItem;
    procedure SetItem(Index: Integer; const Value: TColumnItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner : TComponent);
    function Add: TColumnItem;

    property Items[Index: Integer]: TColumnItem read GetItem write SetItem;
  end;

implementation

{ TColumnCollection }

function TColumnCollection.Add: TColumnItem;
begin
  Result:= inherited Add as TColumnItem;
end;

constructor TColumnCollection.Create(AOwner: TComponent);
begin
  inherited Create(TColumnItem);
  FOwner := AOwner;
end;

function TColumnCollection.GetItem(Index: Integer): TColumnItem;
begin
  Result:= TColumnItem(inherited GetItem(Index));
end;

function TColumnCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TColumnCollection.SetItem(Index: Integer; const Value: TColumnItem);
begin
  inherited SetItem(Index, Value);
end;

end.
