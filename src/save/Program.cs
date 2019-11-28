using System;
using System.Data;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using FnProject.Fdk;
using Microsoft.Extensions.Configuration;
using MySql.Data.MySqlClient;

namespace save
{
	public class Function
	{
		private const string CONNECTION_STRING = "Server={0};Database=dev;Uid=\"root\";Pwd=\"secret123!\";Allow User Variables=True;Pooling=True";
		private const string SQL_COMMAND = "insert into fn (`useragent`, `type`, `date`) VALUES (@useragent, @type, @date)";

		private static MySqlConnection _connection;
		private static MySqlCommand _command;

		static Function()
		{
			var configuration = new ConfigurationBuilder()
				.SetBasePath(Directory.GetCurrentDirectory())
				.AddEnvironmentVariables()
				.Build();

			var dbAddress = configuration["DB_ADDRESS"];

			var connectionString = string.Format(CONNECTION_STRING, dbAddress);
			_connection = new MySqlConnection(connectionString);
			_command = new MySqlCommand(SQL_COMMAND, _connection);
		}

		public async Task<string> InvokeAsync(DetectionResult input, CancellationToken timedOut)
		{
			if (input == null)
				return "ERROR: No DetectionResult is passed to function";

			try
			{
				if (_connection.State != ConnectionState.Open)
					await ConnectToDB(timedOut).ConfigureAwait(false);

				_command.Parameters.Clear();
				_command.Parameters.AddWithValue("@useragent", input.UserAgent);
				_command.Parameters.AddWithValue("@type", input.Type);
				_command.Parameters.AddWithValue("@date", input.Date);

				await _command.ExecuteNonQueryAsync(timedOut).ConfigureAwait(false);
			}
			catch (Exception ex)
			{
				return $"Oops! An error occured. Sorry :( {Environment.NewLine}Here is the reason:{Environment.NewLine}{ex}";
			}

			return "Success";
		}

		private async Task ConnectToDB(CancellationToken cancellationToken)
		{
			await _connection.OpenAsync(cancellationToken).ConfigureAwait(false);
		}

		public static void Main()
		{
			FdkHandler.Handle<Function>();
		}
	}

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
