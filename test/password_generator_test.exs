defmodule PasswordGeneratorTest do
  use ExUnit.Case

  setup do
    options = %{
      "length" => "10",
      "numbers" => "false",
      "symbols" => "false",
      "uppercase" => "false",
    }

    options_type = %{
      lowercase: Enum.map(?a..?z, & <<&1>>),
      numbers: Enum.map(0..9, & Integer.to_string(&1)),
      symbols: String.split("!..?", "", trim: true),
      uppercase: Enum.map(?A..?Z, & <<&1>>)
    }

    {:ok, result} = PasswordGenerator.generate(options)

    %{
      options_type: options_type,
      result: result
    }
  end

  test "returns a string",%{result: result} do
    assert is_bitstring(result)
  end

  test "returns error when no length is given" do
    options = %{"invalid" => "false"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when length is not an integer" do
    options = %{"length" => "ab"}

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "length of returned string is the option provided" do
    length_option = %{"length" => "5"}
    {:ok, result} = PasswordGenerator.generate(length_option)

    assert 5 = String.length(result)
  end

  test "returns a lowercase string just with the length", %{options_type: options} do
    length_option = %{"length" => "5"}
    {:ok, result} = PasswordGenerator.generate(length_option)


    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.symbols)

  end

  test "returns errors when options values are not booleans" do
    options = %{
      "numbers" => "invalid",
      "uppercase" => "0",
      "symbols" => "false",
      "length" => "10"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
    end

    test "returns error when options not allowed" do
      options = %{"length" => "5", "Invalid" => "true"}

      assert {:error, _error} = PasswordGenerator.generate(options)
    end

    test "returns error when 1 option is not allowed" do
      options = %{"length" => "5", "numbers" => "true", "invalid" => "true"}

      assert {:error, _error} = PasswordGenerator.generate(options)
      end

end
