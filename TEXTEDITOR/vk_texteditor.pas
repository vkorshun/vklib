unit vk_texteditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEditRegexSearch, SynEditOptionsDialog, SynEditMiscClasses,
  SynEditSearch, SynEditHighlighter, SynHighlighterCAC, Menus, ComCtrls,
  SynEdit, StdCtrls, Registry;

const
  register_string = '\SOFTWARE\mikko\texteditor';

type
   TVkTextEditor = class( TSynEdit )
   private
   public
     constructor Create(AOwner: TComponent);
     destructor Destroy;
   end;

implementation

end.
