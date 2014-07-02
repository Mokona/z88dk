#!/usr/bin/perl

# Copyright (C) Paulo Custodio, 2011-2014
#
# $Header: /home/dom/z88dk-git/cvs/z88dk/src/z80asm/lib/t/classhash.t,v 1.7 2014-07-02 23:45:12 pauloscustodio Exp $
#
# Test classhash.c

use Modern::Perl;
use Test::More;
use File::Slurp;
use Capture::Tiny 'capture';
use Test::Differences; 

my $compile = "cc -Wall -otest test.c strhash.c strpool.c strutil.c class.c xmalloc.c";

write_file("test.c", <<'END');
#include "classhash.h"

#define ERROR die("Test failed at line %d\n", __LINE__)

CLASS(Obj)
	char *string;
END_CLASS;

void Obj_init (Obj *self) 	{ self->string = xstrdup("Hello World"); }
void Obj_copy (Obj *self, Obj *other)
							{ self->string = xstrdup(other->string); }
void Obj_fini (Obj *self)	{ xfree(self->string); }

DEF_CLASS(Obj);

Obj *new_obj(char *text)
{
	Obj *obj = OBJ_NEW(Obj);
	strcpy(obj->string, text);
	return obj;
}

CLASS_HASH(Obj);
DEF_CLASS_HASH(Obj, TRUE);

int _count;
#define T_START(hash)							\
	iter = ObjHash_first(hash);					\
	_count = 0;

#define T_NEXT(hash, akey, atext)				\
	if (! iter)							ERROR;	\
	obj = iter->value;							\
	if (! obj) 							ERROR;	\
	if (strcmp(iter->key, akey)) 		ERROR;	\
	if (strcmp(obj->string, atext))		ERROR;	\
	if (obj != iter->value)				ERROR;	\
	obj = ObjHash_get(hash, akey);				\
	if (! obj) 							ERROR;	\
	if (strcmp(obj->string, atext))		ERROR;	\
	obj = ObjHash_get(hash, "nokey");			\
	if (obj) 							ERROR;	\
	if (! ObjHash_exists(hash, akey))	ERROR;	\
	if (ObjHash_exists(hash, "nokey"))	ERROR;	\
	iter = ObjHash_next(iter);					\
	_count++;

#define T_END(hash)								\
	if (iter != NULL)					ERROR;	\
	if (hash != NULL && _count != hash->count) ERROR;


int ascending (ObjHashElem *a, ObjHashElem *b)
{
	return strcmp(((Obj *)(a->value))->string, ((Obj *)(b->value))->string);
}

int descending (ObjHashElem *a, ObjHashElem *b)
{
	return strcmp(((Obj *)(b->value))->string, ((Obj *)(a->value))->string);
}

/* reuse string - test saving of keys by hash */
char *S(char *str)
{
	static char buffer[MAXLINE];
	
	strcpy(buffer, str);		/* overwrite last string */
	return buffer;
}

int main()
{
	Obj *obj;
	ObjHash *hash, *hash2;
	ObjHashElem *iter, *elem;
	
	/* not initialized */
	hash = NULL;

	T_START(hash);
	T_END(hash);

	ObjHash_set(&hash, S("abc"), new_obj("321"));

	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_END(hash);
	

	/* initialized */
	OBJ_DELETE(hash);
	hash = OBJ_NEW(ObjHash);
	
	T_START(hash);
	T_END(hash);

	ObjHash_set(&hash, S("abc"), new_obj("321"));
	
	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_END(hash);

	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_END(hash);

	ObjHash_set(&hash, S("def"), new_obj("456"));

	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_NEXT(hash, "DEF", "456");
	T_END(hash);

	ObjHash_set(&hash, S("ghi"), new_obj("789"));

	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	/* set new object, old is deleted */
	ObjHash_set(&hash, S("abc"), new_obj("123"));
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	/* clone */
	hash2 = ObjHash_clone(hash);
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove(hash, S("def"));
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove(hash, S("def"));
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove(hash, S("ghi"));
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove(hash, S("abc"));
	
	T_START(hash);
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove_all(hash);
	
	T_START(hash);
	T_END(hash);

	T_START(hash2);
	T_NEXT(hash2, "ABC", "123");
	T_NEXT(hash2, "DEF", "456");
	T_NEXT(hash2, "GHI", "789");
	T_END(hash2);

	ObjHash_remove_all(hash2);
	
	T_START(hash);
	T_END(hash);

	T_START(hash2);
	T_END(hash2);

	/* first / remove_elem */
	ObjHash_set(&hash, S("ABC"), new_obj("123"));
	ObjHash_set(&hash, S("DEF"), new_obj("456"));
	ObjHash_set(&hash, S("GHI"), new_obj("789"));

	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	elem = ObjHash_first(hash); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "ABC")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	elem = ObjHash_first(hash); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "DEF")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	elem = ObjHash_first(hash); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "GHI")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_END(hash);

	elem = ObjHash_first(hash); 
	if (elem != NULL) ERROR;

	T_START(hash);
	T_END(hash);

	/* find / remove_elem */
	ObjHash_set(&hash, S("abc"), new_obj("123"));
	ObjHash_set(&hash, S("def"), new_obj("456"));
	ObjHash_set(&hash, S("ghi"), new_obj("789"));

	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	elem = ObjHash_find(hash, "def"); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "DEF")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	elem = ObjHash_find(hash, "ghi"); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "GHI")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_NEXT(hash, "ABC", "123");
	T_END(hash);

	elem = ObjHash_find(hash, "abc"); 
	if (elem == NULL) ERROR;
	if (strcmp(elem->key, "ABC")) ERROR;
	ObjHash_remove_elem(hash, elem);
	
	T_START(hash);
	T_END(hash);

	elem = ObjHash_find(hash, "abc"); 
	if (elem != NULL) ERROR;
	
	T_START(hash);
	T_END(hash);

	/* empty */
	OBJ_DELETE(hash);
	hash = OBJ_NEW(ObjHash);

	if (! ObjHash_empty(hash)) ERROR;
	
	ObjHash_set(&hash, S("abc"), new_obj("123"));
	
	if (ObjHash_empty(hash)) ERROR;

	/* sort */
	OBJ_DELETE(hash);
	hash = OBJ_NEW(ObjHash);
	
	ObjHash_set(&hash, S("def"), new_obj("456"));
	ObjHash_set(&hash, S("abc"), new_obj("321"));
	ObjHash_set(&hash, S("ghi"), new_obj("789"));

	T_START(hash);
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "ABC", "321");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	ObjHash_sort(hash, ascending);
	
	T_START(hash);
	T_NEXT(hash, "ABC", "321");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "GHI", "789");
	T_END(hash);

	ObjHash_sort(hash, descending);
	
	T_START(hash);
	T_NEXT(hash, "GHI", "789");
	T_NEXT(hash, "DEF", "456");
	T_NEXT(hash, "ABC", "321");
	T_END(hash);
	
	return 0;
}
END

system($compile) and die "compile failed: $compile\n";
t_capture("./test", "", "", 0);

unlink <test.*>;
done_testing;

sub t_capture {
	my($cmd, $exp_out, $exp_err, $exp_exit) = @_;
	my $line = "[line ".((caller)[2])."]";
	ok 1, "$line command: $cmd";
	
	my($out, $err, $exit) = capture { system $cmd; };
	eq_or_diff_text $out, $exp_out, "$line out";
	eq_or_diff_text $err, $exp_err, "$line err";
	ok !!$exit == !!$exp_exit, "$line exit";
}
