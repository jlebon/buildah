#!/usr/bin/env bats

load helpers

@test "run" {
	if ! which runc ; then
		skip
	fi
	createrandom ${TESTDIR}/randomfile
	cid=$(buildah from --pull --signature-policy ${TESTSDIR}/policy.json --image alpine)
	root=$(buildah mount --name=$cid)
	buildah config --name=$cid --workingdir /tmp
	run buildah --debug=false run --name=$cid pwd
	output=$(echo "$output" | tr -d '\r')
	[ "$output" = /tmp ]
	buildah config --name=$cid --workingdir /root
	run buildah --debug=false run        $cid pwd
	output=$(echo "$output" | tr -d '\r')
	[ "$output" = /root ]
	cp ${TESTDIR}/randomfile $root/tmp/
	buildah run        $cid cp /tmp/randomfile /tmp/other-randomfile
	test -s $root/tmp/other-randomfile
	cmp ${TESTDIR}/randomfile $root/tmp/other-randomfile
	buildah unmount --name=$cid
	buildah delete --name=$cid
}
