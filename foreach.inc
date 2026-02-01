/*----------------------------------------------------------------------------*\
					===========================
					 foreach efficient looping
					===========================
Description:
	Provides efficient looping through sparse data sets, such as connected
	players.  Significantly improved from the original version to be a generic
	loop system, rather then purely a player loop system.  When used for
	players this has constant time O(n) for number of connected players (n),
	unlike standard player loops which are O(MAX_PLAYERS), regardless of the
	actual number of connected players.  Even when n is MAX_PLAYERS this is
	still faster.
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI foreach include.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (C) 2011
	the Initial Developer. All Rights Reserved.
	
	Contributors:
		ZeeX, koolk, JoeBullet/Google63, g_aSlice/Slice, Kar
	
	Thanks:
		JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
		ZeeX - Very productive conversations.
		koolk - IsPlayerinAreaEx code.
		TheAlpha - Danish translation.
		breadfish - German translation.
		Fireburn - Dutch translation.
		yom - French translation.
		50p - Polish translation.
		Zamaroht - Spanish translation.
		Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes
			for me to strive to better.
		Pixels^ - Running XScripters where the idea was born.
		Matite - Pestering me to release it and using it.
	
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
	
Version:
	19 (0.4.2)
Changelog:
	14/05/15:
		Cleaned up the entire include.
	16/07/12:
		Fixed a bug with "loadfs" blocking callbacks.
		Slightly reduced the memory consumption of constant strings.
	25/05/12:
		Added a delay timer to remove players for "Kick" crashes.
	05/01/12:
		Fixed multi-dimensional iterators.
		Fixed "FOREACH_NO_BOTS".
		Made "Iterator:" support multi-dimensional arrays.
	07/12/11:
		Underlying implementation tweak for more consistent code.
		Added Iter_Contains.
	06/12/11:
		Minor fixes.
	31/10/11:
		Changed the underlying loop code to be slightly faster.
		Added support for Iter_SafeRemove, prompting refactoring.
	17/09/11:
		Fixed arrays under the new syntax.
	28/04/11:
		Moved iterator identifiers to end of variables.
		Rewrote "foreach" to accept two syntaxes for "foreach (new i : Iter)".
	16/08/10:
		Removed all the "2" versions of the functions.
	14/08/10:
		Added Iter_Clear to reset an array.
	06/08/10:
		Added special array declaration format.
	18/12/09:
		Added Iter_Func2 functions for multi-dimensional iterators.
		Renamed foreact et al as keywords in the documentation.
		Changed licensing from GPL to MPL.
	02/09/09:
		Fixed (again) for 0.3.
		Added free slot finding.
	21/08/09:
		Updated to include random functions.
		Made entirely stand alone.
		Ported to 0.3 (separate version).
		Added automatic callback hook code.
		Removed debug information from stand alone version.
	06/01/08:
		Added debug information.
	09/10/07:
		Moved to system.
	16/09/07:
		Added list sorting.
		Made this part of Y SeRver Includes, not Y Sever Includes.
		Made list sorting optional.
		Fixed version number.
	08/09/07:
		First version.
Functions:
	Public:
		OnPlayerDisconnect - Called when a player leaves to remove them.
		OnPlayerConnect - Called when a player connects to add them.
	Core:
		-
	Stock:
		Iter_AddInternal - Add a value to an iterator.
		Iter_RemoveInternal - Remove a value from an iterator.
		Iter_RandomInternal - Get a random item from an iterator.
		Iter_FreeInternal - Gets the first free slot in the iterator.
		Iter_InitInternal - Initialises a multi-dimensional iterator.
		Iter_ContainsInternal - Checks if a value is in an iterator.
	Static:
		-
	Inline:
		Iter_Create - Create a new iterator value set.
		Iter_Add - Wraps Iter_AddInternal.
		Iter_SafeRemove - Wraps Iter_SafeRemoveInternal.
		Iter_Remove - Wraps Iter_RemoveInternal.
		Iter_Random - Wraps Iter_RandomInternal.
		Iter_Count - Gets the number of items in an iterator.
		Iter_Free - Wraps around Iter_FreeInternal.
		Iter_Contains - Wraps around Iter_ContainsInternal.
	API:
		-
Callbacks:
	-
Hooks:
	Iter_OnPlayerConnect - Hook for the OnPlayerConnect callback.
	Iter_OnPlayerDisconnect - Hook for the OnPlayerDisconnect callback.
	Iter_OnGameModeInit - Only exists to make the code compile correctly...
Definitions:
	-
Enums:
	-
Macros:
	-
Keywords:
	foreach - Function to loop an iterator.
	foreachex - Like foreach but without a new variable.
Tags:
	Iterator - Declare an iterator.
Variables:
	Global:
		-
	Static:
		YSI_g_OPC - Records whether Iter_OnPlayerConnect exists for speed.
		YSI_g_OPDC - Records whether Iter_OnPlayerDisconnect exists for speed.
Commands:
	-
Compile options:
	FOREACH_NO_BOTS - Remove the bot iterators for smaller code.
	FOREACH_NO_PLAYERS - Remove all default code for player iteration.
Operators:
	-
Iterators:
	Player - List of all players connected.
	Bot - List of all bots (npcs) connected.
	NPC - Alias of Bot.
	Character - All players and bots.
\*----------------------------------------------------------------------------*/

#define _FOREACH_LOCAL_VERSION		19

// Foreach is testing us.
#if defined _FOREACH_INC_TEST
	#define _FOREACH_CUR_VERSION _FOREACH_LOCAL_VERSION
	#endinput
#endif
#if !defined _FOREACH_NO_TEST
	#define _FOREACH_INC_TEST
	#tryinclude <YSI\y_iterate>
	#undef _FOREACH_INC_TEST
	// <foreach> exists - test which is newer.
	#if defined _inc_y_iterate
		#if _FOREACH_CUR_VERSION > _FOREACH_LOCAL_VERSION
			// Foreach is newer.
			#undef _inc_y_iterate
			#define _FOREACH_NO_TEST
			#include <YSI\y_iterate>
			#endinput
		#endif
	#endif
#endif

#if !defined _samp_included
	#error "Please include a_samp or a_npc before foreach"
#endif

#if defined SendChat || defined FOREACH_NO_PLAYERS
	#define BOTSYNC_IS_BOT		(true)
#endif

#if defined IsPlayerNPC
	#define _FOREACH_BOT
#endif

#define ITER_NONE -1

#define _Y_ITER_ARRAY: _:_Y_ITER_C0:
#define _Y_ITER_ARRAY_SIZE(%1) _:_Y_ITER_C1:_Y_ITER_C2:sizeof %1@YSII_Ag-1

#define _Y_ITER_C0:%0[%1]@YSII_%4g%3) %0@YSII_%4g[%1]%3)
#define _Y_ITER_C1:_Y_ITER_C2:%0[%1]@YSII_Ag%3) %0@YSII_Ag[]%3)
#define _Y_ITER_C2:sizeof%0(%1)@YSII_Ag-1;_:(%2=_Y_ITER_ARRAY:%3(%4)@YSII_Ag[%5])!=_Y_ITER_ARRAY_SIZE(%6);) -1;_:(%2=%3@YSII_Ag(%4,%5))!=-1;)

#define _Y_ITER_C3:%0[%1]@YSII_Cg,%2[%3]@YSII_Ag[%4]={%5} _Y_ITER_C3:%0@YSII_Cg[%1],%0@YSII_Ag[%1][%4]

// foreach 19 C2 and C3
//#define _Y_ITER_C2:sizeof%0(%1)@YSII_Ag-1;_:(%2=_Y_ITER_ARRAY:%3(%4)@YSII_Ag[%5])!=%9_Y_ITER_ARRAY_SIZE(%6);) -1;_:(%2=%3@YSII_Ag(%4,%5))!=-1;)
 
//#define _Y_ITER_C3:%0[%1]@YSII_Cg,%2[%3]@YSII_Ag[%4]={%5} _Y_ITER_C3:%0@YSII_Cg[%4-1],%0@YSII_Ag[%1][%4]


#if !defined BOTSYNC_IS_BOT
	static stock
		YSI_g_sCallbacks = 0;
#endif

#if !defined BOTSYNC_IS_BOT
	forward Iter_OPDCInternal(playerid);
#endif

/*----------------------------------------------------------------------------*\
Function:
	Iter_Create2 (unused)
Params:
	name - Iterator identifier.
	size0 - Number of iterators.
	size1 - Number of items per iterator.
Return:
	-
Notes:
	Creates a new array of iterator start/array pair.
\*----------------------------------------------------------------------------*/

// If this ever changes, update the size reference in y_users.
/*#define Iter_Create2(%1,%2,%3) \
	new \
		%1@YSII_Sg[%2] = {-1, ...}, \
		%1@YSII_Cg[%2] = {0}, \
		%1@YSII_Ag[%2][%3]*/

/*----------------------------------------------------------------------------*\
Array:
	IteratorArray
Notes:
	Creates a new iterator array start/array pair.
\*----------------------------------------------------------------------------*/

#define IteratorArray:%1[%2]<%3> %1@YSII_Cg[%2],%1@YSII_Ag[%2][%3+1]//,%1@YSII_Rg[%2][%3+1]

/*----------------------------------------------------------------------------*\
Array:
	Iterator
Notes:
	Creates a new iterator start/array pair.
\*----------------------------------------------------------------------------*/

#define Iterator:%1<%2> _Y_ITER_C3:%1@YSII_Cg,%1@YSII_Ag[(%2)+1]={(%2)*2,(%2)*2-1,...}
#define iterator%0<%1> new Iterator:%0<%1>

/*----------------------------------------------------------------------------*\
Function:
	Iter_Init
Params:
	iter - Name of the iterator array to initialise.
Return:
	-
Notes:
	Wrapper for Iter_InitInternal.

native Iter_Init(IteratorArray:Name[]<>);

\*----------------------------------------------------------------------------*/

#define Iter_Init(%1) \
	Iter_InitInternal(%1@YSII_Ag,sizeof %1@YSII_Ag,sizeof %1@YSII_Ag[]-1)

/*----------------------------------------------------------------------------*\
Function:
	Iter_Create
Params:
	name - Iterator identifier.
	size - Number of values.
Return:
	-
Notes:
	Creates a new iterator start/array pair.
\*----------------------------------------------------------------------------*/

// If this ever changes, update the size reference in y_users.
/*
#define Iter_Create(%1,%2) \
	new \
		%1@YSII_Sg = -1, \
		%1@YSII_Cg = 0, \
		%1@YSII_Ag[%2] = {-1, ...}*/

/*----------------------------------------------------------------------------*\
Function:
	Iter_Add
Params:
	iter - Name of the iterator to add the data to.
	value - Value to add to the iterator.
Return:
	-
Notes:
	Wrapper for Iter_AddInternal.

native Iter_Add(Iterator:Name<>, value);

\*----------------------------------------------------------------------------*/

#define Iter_Add(%1,%2) Iter_AddInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_Free
Params:
	iter - Name of the iterator to get the first free slot in.
Return:
	-
Notes:
	Wrapper for Iter_FreeInternal.

native Iter_Free(Iterator:Name<>);

\*----------------------------------------------------------------------------*/

#define Iter_Free(%1) Iter_FreeInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_Remove
Params:
	iter - Name of the iterator to remove data from.
	value - Data to remove.
Return:
	-
Notes:
	Wrapper for Iter_RemoveInternal.

native Iter_Remove(Iterator:Name<>, value);

\*----------------------------------------------------------------------------*/

#define Iter_Remove(%1,%2) Iter_RemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_Contains
Params:
	iter - Name of the iterator to check membership of.
	value - Value to check.
Return:
	-
Notes:
	Checks if the given value is in the given iterator.

native Iter_Remove(Iterator:Name<>, value);

\*----------------------------------------------------------------------------*/

#define Iter_Contains(%1,%2) Iter_ContainsInternal(_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_SafeRemove
Params:
	iter - Name of the iterator to remove data from.
	value - Data to remove.
	next - Container for the pointer to the next element.
Return:
	-
Notes:
	Wrapper for Iter_SafeRemoveInternal.  Common use:
	
	Iter_SafeRemove(iter, i, i);

native Iter_SafeRemove(Iterator:Name<>, value, &next);

\*----------------------------------------------------------------------------*/

#define Iter_SafeRemove(%1,%2,%3) Iter_SafeRemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,%3,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_Random
Params:
	iter - Name of the iterator to get a random slot from.
Return:
	-
Notes:
	Wrapper for Iter_RandomInternal.

native Iter_Random(Iterator:Name<>);

\*----------------------------------------------------------------------------*/

#define Iter_Random(%1) Iter_RandomInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Function:
	Iter_Count
Params:
	iter - Name of the iterator to get the number of items from.
Return:
	-
Notes:
	Returns the number of items in this iterator.

native Iter_Count(Iterator:Name<>);

\*----------------------------------------------------------------------------*/

#define Iter_Count(%1) (_Y_ITER_ARRAY:%1@YSII_Cg)

/*----------------------------------------------------------------------------*\
Function:
	Iter_Clear
Params:
	iter - Name of the iterator empty.
Return:
	-
Notes:
	Wrapper for Iter_ClearInternal.

native Iter_Clear(IteratorArray:Name[]<>);

\*----------------------------------------------------------------------------*/

#define Iter_Clear(%1) Iter_ClearInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))

/*----------------------------------------------------------------------------*\
Create the internal iterators.
\*----------------------------------------------------------------------------*/

#if !defined BOTSYNC_IS_BOT
	new
		Iterator:Player<MAX_PLAYERS>;
	
	#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
		new
			Iterator:Bot<MAX_PLAYERS>,
			Iterator:Character<MAX_PLAYERS>;
		
		#define NPC@YSII_Cg Bot@YSII_Cg
		#define NPC@YSII_Ag Bot@YSII_Ag
	#endif
#endif

/*----------------------------------------------------------------------------*\
	Variables to optimise memory usage by only having one copy of each string.
	Note that only strings used more than once are put here because only they
	have any gain to being located in only one place.
\*----------------------------------------------------------------------------*/

static stock
	YSI_gsOnPlayerConnect[] = "Iter_OnPlayerConnect",
	YSI_gsOnPlayerDisconnect[] = "Iter_OnPlayerDisconnect",
	YSI_gsOnGameModeInit[] = "Iter_OnGameModeInit",
	YSI_gsSpecifier@[] = "",
	YSI_gsSpecifier@i[] = "i";

/*----------------------------------------------------------------------------*\
Function:
	foreach
Params:
	data - Data to iterate through.
	as - Variable to set value to.
Return:
	-
Notes:
	Not exactly the same as PHP foreach, just iterates through a list and
	returns the value of the current slot but uses that slot as the next index
	too.  Variables must be in the form @YSII_<gname>S for the start index and
	@YSII_<gname>A for the data array where <name> is what's entered in data.
\*----------------------------------------------------------------------------*/

//#define foreach(%1,%2)
//	for (new %2 = %1@YSII_Sg; _:%2 != -1; %2 = %1@YSII_Ag[%2])
#define foreach%1(%0) for(new Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%0|||)
// This allows us to use "new" multiple times - stripping off ONLY whole words.
#define new%0|||%9|||%1:%2||| %9|||%0|||%1|||%2|||

// This one is called if the new syntax is required, but the state of "new" is
// as-yet unknown.  This attempts to call "%1" as a macro, if it starts with
// "new" as a whole word then it will (and will also helpfully strip off the
// "new" keyword for us).
#define Y_FOREACH_THIRD|||%0|||%1|||%2||| %1=Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2|||

// This is called if the "new" macro is called for a second time.
#define Y_FOREACH_FOURTH|||%0=Y_FOREACH_FIFTH|||%1|||%2||| new Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2|||

// This is called when there are tags on the "new" declaration.
#define Y_FOREACH_SEVENTH|||%9Y_FOREACH_SIXTH;%0|||%1|||%2||| new %0:%1=%0:(_Y_ITER_ARRAY_SIZE(%2));_:(%1=%0:_Y_ITER_ARRAY:%2@YSII_Ag[_:%1])!=_Y_ITER_ARRAY_SIZE(%2);

// This is called when there aren't.
#define Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2||| %0=_Y_ITER_ARRAY_SIZE(%2);_:(%0=_Y_ITER_ARRAY:%2@YSII_Ag[%0])!=_Y_ITER_ARRAY_SIZE(%2);
//hta:%0=hta:%2@YSII_Sg;_:%0!=-1;%0=hta:%2@YSII_Ag[%0]
//#define Y_FOREACH_FOURTH|||%0=Y_FOREACH_FIFTH|||%1|||%2||| new hta:%0=hta:%2@YSII_Sg;_:%0!=-1;%0=hta:%2@YSII_Ag[%0]

// Move any tags from the second half to the first half.
//#define hta:%0=hta:%1:%2;_:%3!=-1;%4=hta:%5:%6[%7] %0:%1=%2;_:%1!=-1;%1=%6[%1]

// This is called if "%1" didn't have "new" at the start.
#define Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2||| _Y_ITER_ARRAY_SIZE(%2);_:(%1=_Y_ITER_ARRAY:%2@YSII_Ag[%1])!=_Y_ITER_ARRAY_SIZE(%2);

//%1=%2@YSII_Sg;_:Y_FOREACH_NONEW:%1!=-1;%1=%2@YSII_Ag[%1]
// This is the old version, but DON'T add "new" because that already exists from
// the failed "new" macro call above.
#define Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%1,%2||| %2=_Y_ITER_ARRAY_SIZE(%1);_:(%2=_Y_ITER_ARRAY:%1@YSII_Ag[%2])!=_Y_ITER_ARRAY_SIZE(%1);
//#define Y_FOREACH_NONEW:new%0!=-1;new%1=%2[new%3] %0!=-1;%1=%2[%3]

//#define Y_FOREACH_EIGHTH:%0[%1]@YSII_Sg;%2;%3=%4[%5]@YSII_Ag[%6] %0@YSII_Sg[%1];%2;%3=%4@YSII_Ag[%5][%6]

/*----------------------------------------------------------------------------*\
Function:
	foreachex
Params:
	data - Data to iterate through.
	as - Variable to set value to.
Return:
	-
Notes:
	Similar to foreach but does not declare a new variable for the iterator.
\*----------------------------------------------------------------------------*/

#define foreachex(%1,%2) foreach(%2:%1)
	//for (%2=_Y_ITER_ARRAY_SIZE(%1);(%2=_Y_ITER_ARRAY:%1@YSII_Ag[%2])!=_Y_ITER_ARRAY_SIZE(%1);)

/*----------------------------------------------------------------------------*\
Function:
	Iter_OnPlayerConnect
Params:
	playerid - Player who joined.
Return:
	-
Notes:
	Adds a player to the loop data.  Now sorts the list too.  Note that I found
	the most bizzare bug ever (I *think* it may be a compiler but, but it
	requires further investigation), basically it seems that multiple variables
	were being treated as the same variable (namely @YSII_EgotS and
	@YSII_CgharacterS were the same and @YSII_EgotC and @YSII_CgharacterC were the
	same).  Adding print statements which reference these variables seem to fix
	the problem, and I have tried to make sure that the values will never actually
	get printed.
\*----------------------------------------------------------------------------*/

#if !defined BOTSYNC_IS_BOT
	public OnPlayerConnect(playerid)
	{
		#if defined _FOREACH_BOT
			if (!IsPlayerNPC(playerid))
			{
				Iter_Add(Player, playerid);
			}
			#if !defined FOREACH_NO_BOTS
				else
				{
					Iter_Add(Bot, playerid);
				}
				#pragma tabsize 4
				Iter_Add(Character, playerid);
			#endif
		#else
			Iter_Add(Player, playerid);
		#endif
		if (YSI_g_sCallbacks & 2)
		{
			CallLocalFunction(YSI_gsOnPlayerConnect, YSI_gsSpecifier@i, playerid);
		}
		return 1;
	}
	
	#if defined _ALS_OnPlayerConnect
		#undef OnPlayerConnect
	#else
		#define _ALS_OnPlayerConnect
	#endif
	#define OnPlayerConnect Iter_OnPlayerConnect
	forward OnPlayerConnect(playerid);
#endif

/*----------------------------------------------------------------------------*\
Function:
	Iter_OnFilterScriptInit
Params:
	-
Return:
	-
Notes:
	Fixes a bug where callbacks are not detected when "loadfs" is used after the
	GM has already started.  If this is a GM this is just never used called.
\*----------------------------------------------------------------------------*/

#if !defined BOTSYNC_IS_BOT
	public OnFilterScriptInit()
	{
		if (funcidx(YSI_gsOnPlayerDisconnect) != -1)
		{
			YSI_g_sCallbacks |= 1;
		}
		if (funcidx(YSI_gsOnPlayerConnect) != -1)
		{
			YSI_g_sCallbacks |= 2;
		}
		#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
			Bot@YSII_Cg = _Y_ITER_C3:0;
			