FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 8888

FROM microsoft/dotnet:2.2-sdk AS build
COPY ["stats.csproj", "src/"]
WORKDIR /src

RUN dotnet restore "stats.csproj"
COPY . .
RUN dotnet build "stats.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "stats.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "stats.dll"]
