@echo Compiling proto file(s)...

@protoc empty.proto timestamp.proto wrappers.proto ^
    --proto_path=../third_party/google/protobuf ^
    --plugin=protoc-gen-dart=%USERPROFILE%/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat ^
    --dart_out=grpc:../flutter_client/lib/api/v1/google/protobuf

@protoc chat.proto ^
    --proto_path=../api/proto/v1 ^
    --proto_path=. ^
    --go_out=plugins=grpc:../go-server/pkg/api/v1

@protoc chat.proto ^
    --proto_path=../api/proto/v1 ^
    --proto_path=. ^
    --plugin=protoc-gen-dart=%USERPROFILE%/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat ^
    --dart_out=grpc:../flutter_client/lib/api/v1

@echo Done