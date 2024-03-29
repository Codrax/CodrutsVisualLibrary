unit Cod.AudioBox;

/////////////////////////////////////////////////////////////
///                                                       ///
///                                                       ///
///                        ATTENTION!                     ///
///                                                       ///
///             This component is based on the            ///
///         Bass Audio Library for Delphi (unofficial)    ///
///                                                       ///
///        If you do not have this library, please        ///
///                  download it from:                    ///
///         https://github.com/TDDung/Delphi-BASS         ///
///                                                       ///
///                    Or alternatively..                 ///
///             Remove this unit from the project         ///
///                                                       ///
/////////////////////////////////////////////////////////////

interface
  uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics,
    Controls, Dialogs, ExtCtrls, Menus, Cod.SysUtils, Cod.Audio;

  type
    TAudioBox = class(TComponent)
    private
      Player: TAudioPlayer;

      FFileName,
      FUrl: string;

      function GetPlayStat: TPlayStatus;

      function GetDuration: int64;
      function GetDurationSec: single;

      function GetPosition: int64;
      function GetPosSec: single;

      procedure SetPosition(const Value: int64);
      procedure SetPosSec(const Value: single);

      function GetLoop: boolean;
      procedure SetLoop(const Value: boolean);

      function GetVolume: single;
      procedure SetVolume(const Value: single);

    published
      property FileName: string read FFileName write FFileName;
      property UrlAdress: string read FUrl write FUrl;

      property PlayStatus: TPlayStatus read GetPlayStat;

      property Loop: boolean read GetLoop write SetLoop;

      property Volume: single read GetVolume write SetVolume;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Non-Component properties
      property Duration: int64 read GetDuration;
      property DurationSec: single read GetDurationSec;

      property Position: int64 read GetPosition write SetPosition;
      property PositionSeconds: single read GetPosSec write SetPosSec;

      // Public Proc
      procedure Play;
      procedure Pause;
      procedure Stop;

      procedure OpenFile;
      procedure OpenURL;
      procedure CloseFile;

      function IsFileOpened: boolean;
      function GetCPUUsage: single;
      function GetAudioStream: cardinal;

    end;

implementation

{ TAudioBox }

procedure TAudioBox.CloseFile;
begin
  Player.CloseFile;
end;

constructor TAudioBox.Create(AOwner: TComponent);
begin
  inherited;
  Player := TAudioPlayer.Create;
end;

destructor TAudioBox.Destroy;
begin
  Player.Free;
  inherited;
end;

function TAudioBox.GetAudioStream: cardinal;
begin
  Result := Player.Stream;
end;

function TAudioBox.GetCPUUsage: single;
begin
  Result := Player.GetCPUUsage;
end;

function TAudioBox.GetDuration: int64;
begin
  Result := Player.Duration;
end;

function TAudioBox.GetDurationSec: single;
begin
  Result := Player.DurationSeconds;
end;

function TAudioBox.GetLoop: boolean;
begin
  Result := Player.Loop;
end;

function TAudioBox.GetPlayStat: TPlayStatus;
begin
  Result := Player.PlayStatus;
end;

function TAudioBox.GetPosition: int64;
begin
  Result := Player.Position;
end;

function TAudioBox.GetPosSec: single;
begin
  Result := Player.PositionSeconds;
end;

function TAudioBox.GetVolume: single;
begin
  Result := Player.Volume;
end;

function TAudioBox.IsFileOpened: boolean;
begin
  Result := Player.IsFileOpen;
end;

procedure TAudioBox.OpenFile;
begin
  Player.OpenFile( FFileName );
end;

procedure TAudioBox.OpenURL;
begin
  Player.OpenURL( FURL );
end;

procedure TAudioBox.Pause;
begin
  Player.Pause;
end;

procedure TAudioBox.Play;
begin
  Player.Play;
end;

procedure TAudioBox.SetLoop(const Value: boolean);
begin
  Player.Loop := Value;
end;

procedure TAudioBox.SetPosition(const Value: int64);
begin
  Player.Position := Value;
end;

procedure TAudioBox.SetPosSec(const Value: single);
begin
  Player.PositionSeconds := Value;
end;

procedure TAudioBox.SetVolume(const Value: single);
begin
  Player.Volume := Value;
end;

procedure TAudioBox.Stop;
begin
  Player.Stop
end;

end.
