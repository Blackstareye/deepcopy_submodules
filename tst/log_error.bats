#!/usr/bin/env bats

@function setup() {
    load "config.conf"
}
@test "Test no logpath given" {
    run 
  [ "$status" -eq 1 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
@test "Test no init before use" {
    run 
  [ "$status" -eq 1 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
