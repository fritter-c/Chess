unit ChessMessages;

interface

uses
  Messages;

const
  WM_NEW_MOVE = WM_USER + 100;
  WM_NEW_GAME = WM_NEW_MOVE + 1;
  WM_NEW_CONFIG = WM_NEW_GAME + 1;
  WM_NEW_PROMOTE = WM_NEW_GAME + 1;

  WM_CONNECTIONCHANGED = WM_NEW_PROMOTE + 1;
  WM_CONNECT           = WM_CONNECTIONCHANGED + 1;

  WM_PROCESS_NEW_MOVE  =  WM_CONNECT + 1;
implementation

end.
