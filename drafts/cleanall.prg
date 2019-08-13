/*
CLEANALL - make a clean on temporary files, and GUI folders
*/

#include "directry.ch"
#include "inkey.ch"

PROCEDURE Main

   LOCAL nBytesDeleted := 0, nFilesDeleted := 0

   SetMode( 33, 100 )
   CLS
   DeleteAll( "c:\temp\", @nBytesDeleted, @nFilesDeleted, .F. )
   DeleteHbmk( "d:\", @nBytesDeleted, @nFilesDeleted )
   ? "Deleted " + Ltrim( Str( nFilesDeleted ) ) + " File(s), Size " + Ltrim( Transform( nBytesDeleted, "@E 999,999,999,999,999" ) )
   ? "Press any key"
   Inkey(10)

   RETURN

STATIC FUNCTION DeleteHbmk( cPath, nBytesDeleted, nFilesDeleted )

   LOCAL aFiles, oFile

   aFiles := Directory( cPath + "*.*", "DSH" )
   FOR EACH oFile IN aFiles
      GrafProc()
      DO CASE
      CASE Upper( oFile[ F_NAME ] ) == "."
      CASE Upper( oFile[ F_NAME ] ) == ".."
      CASE "D" $ oFile[ F_ATTR ]
         IF Upper( oFile[ F_NAME ] ) == ".HBMK" .OR. ;
               ( "\GITHUB\HARBOUR34\" $ Upper( cPath ) .AND. ;
               ( "\OBJ\WIN\" $  Upper( cPath ) .OR. "\OBJ\LINUX" $ Upper( cPath ) ) )
            DeleteAll( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
         ELSE
            DeleteHbmk( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
         ENDIF
      ENDCASE
   NEXT

   RETURN NIL

STATIC FUNCTION DeleteAll( cPath, nBytesDeleted, nFilesDeleted, lRemoveFolder )

   LOCAL aFiles, oFile

   hb_Default( @lRemoveFolder, .T. )
   ? cPath
   aFiles := Directory( cPath + "*.*", "D" )
   FOR EACH oFile IN aFiles
      DO CASE
      CASE oFile[ F_NAME ] == "."
      CASE oFile[ F_NAME ] == ".."
      CASE "D" $ oFile[ F_ATTR ]
         DeleteAll( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
      OTHERWISE
         ? "Deleting " + cPath + oFile[ F_NAME ]
         nBytesDeleted += FileSize( cPath + oFile[ F_NAME ] )
         nFilesDeleted += 1
         fErase( cPath + oFile[ F_NAME ] )
      ENDCASE
   NEXT
   IF lRemoveFolder
      ? "Deleting Folder " + Left( cPath, Len( cPath ) - 1 )
      DirRemove( Left( cPath, Len( cPath ) - 1 ) )
   ENDIF

   RETURN NIL

STATIC FUNCTION FileSize( cFile )

   LOCAL aFiles, nSize := 0

   aFiles := Directory( cFile )
   IF Len( aFiles ) > 0
      nSize := aFiles[ 1, F_SIZE ]
   ENDIF

   RETURN nSize

STATIC FUNCTION GrafProc()

   STATIC StaticProc := 1
   STATIC StaticTime := "X"

   LOCAL nRow, nCol

   IF StaticTime != Time()
      nRow := Row()
      nCol := Col()
      @ MaxRow(), 0 SAY Substr( "|/-\", StaticProc, 1 )
      StaticProc += iif( StaticProc == 4, -3, 1 )
      @ nRow, nCol SAY ""
      StaticTime := Time()
   ENDIF

   RETURN NIL
