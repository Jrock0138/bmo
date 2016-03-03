# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

##################
#Bugzilla Test 13#
#####schema#######

# Check the Bugzilla database schema to ensure no field names conflict
# with SQL reserved words.

use 5.14.0;
use strict;
use warnings;

use lib qw(. lib local/lib/perl5 t);
use Bugzilla;
use Bugzilla::DB::Schema;


# SQL reserved words
use constant RESERVED_WORDS => qw(
    ABSOLUTE ACTOR ADD AFTER ALL ALLOCATE ALTER ANY AND ARE AS ASC ASSERTION ASYNC AT
    ATTRIBUTES BEFORE BEGIN BETWEEN BIT BIT_LENGTH BOOLEAN BOTH BREADTH BY CALL CASCADE
    CASCADED CASE CAST CATALOG CHAR CHARACTER_LENGTH CHAR_LENGTH COLLATE
    COLLATION COLUMN COMPLETION CONNECT CONNECTION CONSTRAINT CONSTRAINTS
    CONVERT CORRESPONDING CREATE CROSS CURRENT_DATE CURRENT_PATH CURRENT_TIME
    CURRENT_TIMESTAMP CURRENT_USER CYCLE DATE DAY DEALLOCATE DECLARE DEFAULT DEFERRABLE
    DEFERRED DELETE DEPTH DESC DESCRIBE DESCRIPTOR DESTROY DIAGNOSTICS DICTIONARY
    DISCONNECT DISTINCT DO DROP EACH ELEMENT ELSE ELSEIF END END-EXEC EQUALS EXCEPT
    EXCEPTION EXECUTE EXTERNAL EXTRACT FACTOR FALSE FIRST FOR FROM FULL GENERAL GET
    GLOBAL GRANT GROUP HAVING HOLD HOUR IDENTITY IF IGNORE IMMEDIATE IN INITIALLY INNER INPUT
    INSENSITIVE INSERT INSTEAD INTERSECT INTERVAL IS ISOLATION JOIN LAST LEADING LEAVE
    LEFT LESS LEVEL LIMIT LIST LOCAL LOOP LOWER MATCH MINUTE MODIFY MONTH NAMES
    NATIONAL NATURAL NCHAR NEW NEW_TABLE NEXT NO NONE NOT NULL NULLIF OBJECT
    OCTET_LENGTH OFF OID OLD OLD_TABLE ONLY OPERATION OPERATOR OPERATORS OR ORDER OTHERS
    OUTER OUTPUT OVERLAPS PAD PARAMETERS PARTIAL PATH PENDANT POSITION POSTFIX
    PREFIX PREORDER PREPARE PRESERVE PRIOR PRIVATE PROTECTED READ RECURSIVE REF
    REFERENCING RELATIVE REPLACE RESIGNAL RESTRICT RETURN RETURNS REVOKE RIGHT
    ROLE ROUTINE ROW ROWS SAVEPOINT SCROLL SEARCH SECOND SELECT SENSITIVE SEQUENCE
    SESSION SESSION_USER SIGNAL SIMILAR SIZE SPACE SQLEXCEPTION SQLSTATE
    SQLWARNING START STATE STRUCTURE SUBSTRING SYMBOL SYSTEM_USER TABLE TEMPORARY
    TERM TEST THEN THERE TIME TIMEZONE_HOUR TIMEZONE_MINUTE TRAILING
    TRANSACTION TRANSLATE TRANSLATION TRIGGER TRIM TRUE TUPLE UNDER
    UNKNOWN UNION UNIQUE UPDATE UPPER USAGE USING VARCHAR VARIABLE VARYING VIEW VIRTUAL VISIBLE
    WAIT WHEN WHERE WHILE WITH WITHOUT WRITE YEAR ZONE
);

# Few Exceptions are removed from the above list
# i.e. VALUE, TYPE, ALIAS, COALESCE

our $dbh;
our $schema;
our @tables;

BEGIN {
    $schema = Bugzilla::DB::Schema->new("Mysql");
    @tables = $schema->get_table_list();
}

use Test::More tests => scalar(@tables);

foreach my $table (@tables) {
    my @reserved;

    if (grep { uc($table) eq $_ } RESERVED_WORDS) {
        push(@reserved, $table);
    }

    foreach my $column ($schema->get_table_columns($table)) {
        if (grep { uc($column) eq $_ } RESERVED_WORDS) {
            push(@reserved, $column);
        }
    }

    if (scalar @reserved) {
        ok(0, "Table $table use reserved words: " . join(", ", @reserved));
    }
    else {
        ok(1, "Table $table does not use reserved words");
    }
}

exit 0;
