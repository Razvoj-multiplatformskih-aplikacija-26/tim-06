
FROM dart:3.13.5 AS build
WORKDIR /workspace
COPY <<PUBSPEC pubspec.yaml
name: staze_server_image
environment:
  sdk: ^3.13.5
workspace:
  - packages/domain
  - packages/use_cases
  - packages/fake_data
  - packages/api_contract
  - packages/api_mapping
  - apps/server
PUBSPEC
COPY pubspec.lock ./
COPY packages/domain packages/domain
COPY packages/use_cases packages/use_cases
COPY packages/fake_data packages/fake_data
COPY packages/api_contract packages/api_contract
COPY packages/api_mapping packages/api_mapping
COPY apps/server apps/server
RUN dart pub get
RUN dart compile exe apps/server/bin/server.dart -o /server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /app/server
WORKDIR /app
ENV HOST=0.0.0.0
USER 65532:65532
EXPOSE 8080
CMD ["/app/server"]