FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY artifacts/v1 .
ENTRYPOINT ["dotnet", "Yawa.Api.dll"]