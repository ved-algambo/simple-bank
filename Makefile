DB_SOURCE=postgresql://myuser:mypass@localhost:5432/simplebank?sslmode=disable

postgres:
	docker run --name postgres --network bank-network -p 5432:5432 -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypass -d postgres:12-alpine


createdb:
	docker exec -it postgres createdb --username=myuser --owner=root simplebank

dropdb:
	docker exec -it postgres dropdb simplebank

migrateup:
	migrate -path db/migration -database "postgresql://myuser:mypass@localhost:5432/simplebank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://myuser:mypass@localhost:5432/simplebank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	@reflex -r '\.(go|env)' -s -- sh -c "go run ."

proto:
	@protoc --experimental_allow_proto3_optional --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto
	
evans:
	evans --host localhost --port 9090 -r repl

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine