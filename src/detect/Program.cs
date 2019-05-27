using System;
using System.IO;
using System.Net;
using System.Runtime.Serialization.Formatters.Binary;
using System.Threading;
using System.Threading.Tasks;
using FnProject.Fdk;
using Microsoft.Extensions.Configuration;
using RestSharp;

namespace detect
{
	public class Function
	{
		private static readonly string FN_ADDRESS;
		static Function()
		{
			var configuration = new ConfigurationBuilder()
				.SetBasePath(Directory.GetCurrentDirectory())
				.AddEnvironmentVariables()
				.Build();

			FN_ADDRESS = configuration["FN_ADDRESS"];
		}

		public Task<string> InvokeAsync(string input, IContext ctx, CancellationToken timedOut)
		{
			if (ctx.Headers.TryGetValue("User-Agent", out var userAgent))
			{
				if (userAgent.ToString().Contains("iphone", System.StringComparison.OrdinalIgnoreCase))
				{
					return SaveAsync(new DetectionResult(userAgent, 0, DateTime.UtcNow));
				}
				else if (userAgent.ToString().Contains("android", System.StringComparison.OrdinalIgnoreCase))
				{
					return SaveAsync(new DetectionResult(userAgent, 1, DateTime.UtcNow));
				}
				else
					return SaveAsync(new DetectionResult(userAgent, 2, DateTime.UtcNow));
			}

			return Task.FromResult("No user agent found");
		}

		private static Task<string> SaveAsync(DetectionResult result)
		{
			try
			{
				var type =
					result.Type == 0
					? "iPhone detected!"
					: result.Type == 1
						? "Android detected!"
						: "User-agent doesn't look like a phone. Don't cheat ;)";

				var client = new RestClient($"http://{FN_ADDRESS}:8080/t/devdays/save");
				var request = new RestRequest(Method.POST);
				request.AddJsonBody(result);

				var response = client.Post(request);
				return Task.FromResult(type);
			}
			catch (Exception ex)
			{
				return Task.FromResult(ex.ToString());
			}
		}

		private static byte[] ToByteArray(DetectionResult result)
		{
			var bf = new BinaryFormatter();
			using (var ms = new MemoryStream())
			{
				bf.Serialize(ms, result);
				return ms.ToArray();
			}
		}

		public static void Main()
		{
			FdkHandler.Handle<Function>();
		}
	}

	[Serializable]
	public class DetectionResult
	{
		public DetectionResult(string userAgent, byte type, DateTime date)
		{
			UserAgent = userAgent;
			Type = type;
			Date = date;
		}

		public string UserAgent { get; }
		public byte Type { get; }
		public DateTime Date { get; }
	}
}
