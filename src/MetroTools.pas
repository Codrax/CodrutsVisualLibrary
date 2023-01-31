unit MetroTools;

interface
  uses System.Classes;

Type
  TMPersistent = class(TPersistent)
    Owner : TPersistent;
    constructor Create(AOwner : TPersistent); overload; virtual;
  end;

implementation


constructor TMPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  Owner := AOwner;
end;

end.
