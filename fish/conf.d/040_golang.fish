# golang
# Aliases: gob goc god goe gof gofa gofx gog goga goi gol gom gomt gopa
#          gopb gops gor got gota goto gotoc gotod gotofx gov gove gow
if not contains "golang" $cogs
    return 0
end

abbr -a gob 'go build'
abbr -a goc 'go clean'
abbr -a god 'go doc'
abbr -a goe 'go env'
abbr -a gof 'go fmt'
abbr -a gofa 'go fmt ./...'
abbr -a gofx 'go fix'
abbr -a gog 'go get'
abbr -a goga 'go get ./...'
abbr -a goi 'go install'
abbr -a gol 'go list'
abbr -a gom 'go mod'
abbr -a gomt 'go mod tidy'
abbr -a gopa 'cd $GOPATH'
abbr -a gopb 'cd $GOPATH/bin'
abbr -a gops 'cd $GOPATH/src'
abbr -a gor 'go run'
abbr -a got 'go test'
abbr -a gota 'go test ./...'
abbr -a goto 'go tool'
abbr -a gotoc 'go tool compile'
abbr -a gotod 'go tool dist'
abbr -a gotofx 'go tool fix'
abbr -a gov 'go vet'
abbr -a gove 'go version'
abbr -a gow 'go work'
