/*
Utilities working files.

Copyright (C) Paulo Custodio, 2011-2014

$Header: /home/dom/z88dk-git/cvs/z88dk/src/z80asm/lib/fileutil.h,v 1.6 2014-01-20 23:29:18 pauloscustodio Exp $
*/

#pragma once

#include "xmalloc.h"   /* before any other include */

#include "list.h"
#include "strutil.h"
#include "types.h"

#include <stdio.h>

/* File name extension separator */
#ifdef QDOS
#define FILEEXT_SEPARATOR "_"
#else
#define FILEEXT_SEPARATOR "."
#endif

/*-----------------------------------------------------------------------------
*   Define a Str to hold a filename
*----------------------------------------------------------------------------*/
#define DEFINE_FILE_STR( name )		DEFINE_STR( name, FILENAME_MAX )

/*-----------------------------------------------------------------------------
*   File input/output
*	Register callbacks to be used on fatal read/write of a file.
*	Fatal error if number of chars read/writen not same as requested
*   Use fwrite/fread instead for checking.
*----------------------------------------------------------------------------*/
typedef void (*ferr_callback_t)(char *filename, BOOL writing);

/* set call-back for input/output error; return old call-back */
extern ferr_callback_t set_ferr_callback( ferr_callback_t func );

/* OS interface with fatal errors on failure */
extern FILE *xfopen( char *filename, char *mode );
extern void  xfclose( FILE *file );

/* read/write buffers */
extern void xfwrite( void *buffer, size_t size, size_t count, FILE *file );
extern void xfread(  void *buffer, size_t size, size_t count, FILE *file );

/* read/write strings of characters */
extern void xfput_chars( FILE *file, char *buffer, size_t len );
extern void xfget_chars( FILE *file, char *buffer, size_t len );

/* read/write Str */
extern void xfput_strz( FILE *file, char *str );
extern void xfput_Str(  FILE *file, Str  *str );
extern void xfget_Str(  FILE *file, Str  *str, size_t len );

/* read/write counted string - string with size byte/word at start */
extern void xfput_count_byte_strz( FILE *file, char *str );
extern void xfput_count_byte_Str(  FILE *file, Str  *str );
extern void xfget_count_byte_Str(  FILE *file, Str  *str );

extern void xfput_count_word_strz( FILE *file, char *str );
extern void xfput_count_word_Str(  FILE *file, Str  *str );
extern void xfget_count_word_Str(  FILE *file, Str  *str );

/* read/write numbers */
extern void xfput_int8(  FILE *file, int        value );
extern void xfput_uint8( FILE *file, unsigned   value );
extern void xfget_int8(  FILE *file, int      *pvalue );
extern void xfget_uint8( FILE *file, unsigned *pvalue );

extern void xfput_int16(  FILE *file, int        value );
extern void xfput_uint16( FILE *file, unsigned   value );
extern void xfget_int16(  FILE *file, int      *pvalue );
extern void xfget_uint16( FILE *file, unsigned *pvalue );

extern void xfput_int32(  FILE *file, long            value );
extern void xfput_uint32( FILE *file, unsigned long   value );
extern void xfget_int32(  FILE *file, long          *pvalue );
extern void xfget_uint32( FILE *file, unsigned long *pvalue );

/*-----------------------------------------------------------------------------
*   Pathname manipulation
*   All filenames are returned in fixed length Str defined by
*	DEFINE_STR( dest, FILENAME_MAX ).
*	Input string is unchanged.
*	Basename is file name removing all directories.
*	Extension is the final "." followed by sequence of letters or digits
*----------------------------------------------------------------------------*/
extern void path_remove_ext( Str *dest, char *filename );
extern void path_replace_ext( Str *dest, char *filename, char *new_ext );
extern void path_basename( Str *dest, char *filename );

/* search for a file on the given directory list, return full path name */
extern void path_search( Str *dest, char *filename, List *dir_list );
extern char *search_file( char *filename, List *dir_list );	/* returned string in strpool */


/*
* $Log: fileutil.h,v $
* Revision 1.6  2014-01-20 23:29:18  pauloscustodio
* Moved file.c to lib/fileutil.c
*
* Revision 1.5  2014/01/15 00:01:40  pauloscustodio
* Decouple file.c from errors.c by adding a call-back mechanism in file for
* fatal errors, setup by errors_init()
*
* Revision 1.4  2014/01/11 01:29:40  pauloscustodio
* Extend copyright to 2014.
* Move CVS log to bottom of file.
*
* Revision 1.3  2014/01/11 00:10:39  pauloscustodio
* Astyle - format C code
* Add -Wall option to CFLAGS, remove all warnings
*
* Revision 1.2  2014/01/02 17:18:16  pauloscustodio
* StrList removed, replaced by List
*
* Revision 1.1  2014/01/01 21:23:49  pauloscustodio
* Move generic file utility functions to lib/fileutil.c
*
*
*/
