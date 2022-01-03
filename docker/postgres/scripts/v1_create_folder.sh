#!/bin/bash
cd  /var/lib/postgresql/data/pg_tblspc/
mkdir "$POSTGRES_DB"
cd "$POSTGRES_DB"/
mkdir tbs_"$POSTGRES_DB"_d tbs_"$POSTGRES_DB"_i