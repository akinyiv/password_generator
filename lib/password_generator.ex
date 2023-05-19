defmodule PasswordGenerator do
  @moduledoc """
  Generates random passwords depending on parameters. The main function is 'generate(options)'.
  This function takes an options map. Example options:

  options = %{
    "length" => "5",
    "uppercase" => "false",
    "symbols" => "false",
    "numbers" => "false"
  }
  """

  @allowed_options [:length, :numbers, :uppercase, :symbols]

  @doc """
  Generates a password for the given options.

  ## Examples

  options = %{
    "length" => "5",
    "uppercase" => "false",
    "symbols" => "false",
    "numbers" => "false"
  }

  iex> PasswordGenerator.generate(options)
  "asdfg"

  options = %{
    "length" => "5",
    "uppercase" => "false",
    "symbols" => "false",
    "numbers" => "true"
  }

  iex> PasswordGenerator.generate(options)
  "asdf1"
  """

  @spec generate(options :: map()) :: {:ok, String.t()} | {:error, String.t()}
  def generate(options) do
    length = Map.has_key?(options, "length")
    validate_length(length, options)
  end

  defp validate_length(false, _options) do
    {:error, "Please provide a length"}
  end

  defp validate_length(true, options) do
    length = options["length"]
    length = String.contains?(length, Enum.map(0..9, &to_string/1))
    validate_length_is_integer(length, options)
  end

  defp validate_length_is_integer(false, _options) do
    {:error, "Only integers are allowed for the length"}
  end

  defp validate_length_is_integer(true, options) do
    length = options["length"] |> String.trim() |> String.to_integer()
    options_without_length = Map.delete(options, "length")
    options_values = Map.values(options_without_length)

    value = options_values |> Enum.all?(fn x ->String.to_atom(x) |> is_boolean()end)

    validate_options_values_are_booleans(value, length, options_without_length)
  end

  defp validate_options_values_are_booleans(false, _length, _options) do
    {:error, "Only booleans are allowed for option values"}
  end

  defp validate_options_values_are_booleans(true, length, options) do
    options = included_options(options)
    invalid_options? = options |> Enum.any?(&(&1 not in @allowed_options))
    validate_options(invalid_options?, length, options)
  end

  defp validate_options(true, _length, _options) do
    {:error, "Only the following options are allowed: length, numbers, uppercase, symbols"}
  end

  defp validate_options(false, length, options) do
    generate_strings(length, options)
  end

  defp generate_strings(length, options) do
    options = [:lowercase_letter | options]
    included = include(options)
    length = length - length(included)
    random_strings = generate_random_strings(length, options)
    strings = included ++ random_strings
    get_result(strings)
  end

  defp get_result(strings) do
    string =
      strings
      |> Enum.shuffle()
      |> List.to_string()

    {:ok, string}
  end

  defp include(options) do
    options |> Enum.map(&get/1)
  end

  defp get(:lowercase_letter) do
    <<Enum.random(?a..?z)>>
  end

  defp generate_random_strings(length, options) do
    Enum.map(1..length, fn _ ->
      Enum.random(options) |> get()
    end)
  end

  defp included_options(options) do
    Enum.filter(options, fn {_key, value} ->
      value |> String.trim() |> String.to_existing_atom()
    end) |> Enum.map(fn {key, _value} -> String.to_atom(key) end)
  end
end
