﻿using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace stats
{
	public class Program
	{
		public static void Main(string[] args)
		{
			CreateWebHostBuilder(args).Build().Run();
		}


		public static IWebHostBuilder CreateWebHostBuilder(string[] args)
		{
			var config = new ConfigurationBuilder()
				.AddEnvironmentVariables()
				.Build();

			return WebHost.CreateDefaultBuilder(args)
				.UseConfiguration(config)
				.UseKestrel()
				.UseStartup<Startup>();
		}
	}
}
