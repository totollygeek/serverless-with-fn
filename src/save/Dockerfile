FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY ["save.csproj", "."]
RUN dotnet restore "save.csproj"
COPY . .
RUN dotnet build "save.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "save.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "save.dll"]