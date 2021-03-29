#!/usr/bin/env bash
# this is the test set for validation tests

declare -a HTTP_syn_faulty=("htta://a.b.c" "http://a.:809b:.c" "abcd?abs.de", "a.b.c", "")
declare -a HTTPS_syn_faulty=("htta://a.b.c" "http://a.:809b:.c" "abcd?abs.de", "a.b.c", "")
declare -a SSH_syn_faulty=("user@a@domain.de" "@domain.de" "abs.de", "")
declare -a SSH_syn_sucess=("user@domain.de" "user:password@domain.de" "domain.de")
declare -a HTTP_syn_sucess=("http://a.b.c" "http://domain:890" "a.b.c",)
declare -a HTTPS_syn_sucess=("https://a.b.c" "https://domain:890" "https://a.b.c/test")

declare -a SSH_sem_sucess=("localhost")
declare -a HTTPS_sem_sucess=("https://www.ecosia.org" "https://duckduckgo.com")

#declare -a HTTP[sem_sucess]=("http://a.b.c" "http://domain:890" "a.b.c",)
declare -a TYPE_sucess=("remote" "local")
declare -a TYPE_faulty=("remaote" "loacal" "" "foobar")

declare -a PATH_sucess=("/tmp/" "/tmp/" "/tmp//" "~")
declare -a PATH_faulty=("//a" "http://a.b.c" "" " ")

print_array() {
    echo "HTTP_syn_faulty: ${HTTP_syn_faulty[*]}"
    echo "HTTPS_syn_faulty: ${HTTPS_syn_faulty[*]}"
    echo "SSH_syn_faulty: ${SSH_syn_faulty[*]}"
    echo "SSH_syn_sucess: ${SSH_syn_sucess[*]}"
    echo "HTTP_syn_sucess: ${HTTP_syn_sucess[*]}"
    echo "HTTPS_syn_sucess: ${HTTPS_syn_sucess[*]}"
    echo "SSH_sem_sucess: ${SSH_sem_sucess[*]}"
    echo "HTTPS_sem_sucess: ${HTTPS_sem_sucess[*]}"
    echo "TYPE_sucess: ${TYPE_sucess[*]}"
    echo "TYPE_faulty: ${TYPE_faulty[*]}"
    echo "PATH_sucess: ${PATH_sucess[*]}"
    echo "PATH_faulty: ${PATH_faulty[*]}"
}

