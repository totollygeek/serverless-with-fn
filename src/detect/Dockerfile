FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY ["detect.csproj", "."]
RUN dotnet restore "detect.csproj"
COPY . .
RUN dotnet build "detect.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "detect.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "detect.dll"]