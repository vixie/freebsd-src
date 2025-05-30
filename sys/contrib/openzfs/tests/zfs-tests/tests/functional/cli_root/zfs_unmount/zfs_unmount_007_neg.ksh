#!/bin/ksh -p
# SPDX-License-Identifier: CDDL-1.0
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or https://opensource.org/licenses/CDDL-1.0.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2016 by Delphix. All rights reserved.
#

. $STF_SUITE/tests/functional/cli_root/zfs_mount/zfs_mount.kshlib
. $STF_SUITE/tests/functional/cli_root/zfs_unmount/zfs_unmount.kshlib

#
# DESCRIPTION:
#	Try each 'zfs unmount' with inapplicable scenarios to make sure
#	it returns an error. include:
#		* Multiple filesystem|mountpoint specified
#		* '-a', but also with a specific filesystem|mountpoint.
#
# STRATEGY:
#	1. Create an array of parameters
#	2. For each parameter in the array, execute the sub-command
#	3. Verify an error is returned.
#

verify_runnable "both"

multifs="$TESTFS $TESTFS1"
datasets=""

for fs in $multifs ; do
	datasets="$datasets $TESTPOOL/$fs"
done

set -A args "$unmountall $TESTPOOL/$TESTFS" \
	"$unmountcmd $datasets"

function setup_all
{
	typeset fs

	for fs in $multifs ; do
		setup_filesystem "$DISKS" "$TESTPOOL" \
			"$fs" \
			"${TEST_BASE_DIR%%/}/testroot$$/$TESTPOOL/$fs"
	done
	return 0
}

function cleanup_all
{
	typeset fs

	cleanup_filesystem "$TESTPOOL" "$TESTFS1"
	log_must zfs set mountpoint=$TESTDIR $TESTPOOL/$TESTFS

	[[ -d ${TEST_BASE_DIR%%/}/testroot$$ ]] && \
		rm -rf ${TEST_BASE_DIR%%/}/testroot$$

	return 0
}

function verify_all
{
	typeset fs

	for fs in $multifs ; do
		log_must mounted $TESTPOOL/$fs
	done
	return 0
}

log_assert "Badly-formed 'zfs $unmountcmd' with inapplicable scenarios " \
	"should return an error."
log_onexit cleanup_all

log_must setup_all

typeset -i i=0
while (( i < ${#args[*]} )); do
	log_mustnot zfs ${args[i]}
	((i = i + 1))
done

log_must verify_all

log_pass "Badly formed 'zfs $unmountcmd' with inapplicable scenarios " \
	"fail as expected."
