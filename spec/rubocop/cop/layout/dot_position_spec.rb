# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::DotPosition, :config do
  context 'Leading dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'leading' } }

    it 'registers an offense for trailing dot in multi-line call' do
      expect_offense(<<~RUBY)
        something.
                 ^ Place the . on the next line, together with the method name.
          method_name
      RUBY

      expect_correction(<<~RUBY)
        something
          .method_name
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<~RUBY)
        something
          .method_name
        something.
                 ^ Place the . on the next line, together with the method name.
          method_name
      RUBY

      expect_correction(<<~RUBY)
        something
          .method_name
        something
          .method_name
      RUBY
    end

    it 'registers an offense for only dot line' do
      expect_offense(<<~RUBY)
        foo
          .bar
          .
          ^ Place the . on the next line, together with the method name.
          baz
      RUBY

      expect_correction(<<~RUBY)
        foo
          .bar
          .baz
      RUBY
    end

    it 'accepts leading do in multi-line method call' do
      expect_no_offenses(<<~RUBY)
        something
          .method_name
      RUBY
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      expect_offense(<<~RUBY)
        l.
         ^ Place the . on the next line, together with the method name.
        (1)
      RUBY

      expect_correction(<<~RUBY)
        l
        .(1)
      RUBY
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    context 'when there is an intervening line comment' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          something.
          # a comment here
            method_name
        RUBY
      end
    end

    context 'when there is an intervening blank line' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          something.

            method_name
        RUBY
      end
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for correct + opposite' do
        expect_offense(<<~RUBY)
          something
            &.method_name
          something&.
                   ^^ Place the &. on the next line, together with the method name.
            method_name
        RUBY

        expect_correction(<<~RUBY)
          something
            &.method_name
          something
            &.method_name
        RUBY
      end

      it 'accepts leading do in multi-line method call' do
        expect_no_offenses(<<~RUBY)
          something
            &.method_name
        RUBY
      end
    end

    context 'with multiple offenses' do
      it 'registers all of them' do
        expect_offense(<<~RUBY)
          @objects = @objects.where(type: :a)

          @objects = @objects.
                             ^ Place the . on the next line, together with the method name.
            with_relation.
                         ^ Place the . on the next line, together with the method name.
            paginate
        RUBY

        expect_correction(<<~RUBY)
          @objects = @objects.where(type: :a)

          @objects = @objects
            .with_relation
            .paginate
        RUBY
      end
    end
  end

  context 'Trailing dots style' do
    let(:cop_config) { { 'EnforcedStyle' => 'trailing' } }

    it 'registers an offense for leading dot in multi-line call' do
      expect_offense(<<~RUBY)
        something
          .method_name
          ^ Place the . on the previous line, together with the method call receiver.
      RUBY

      expect_correction(<<~RUBY)
        something.
          method_name
      RUBY
    end

    it 'accepts trailing dot in multi-line method call' do
      expect_no_offenses(<<~RUBY)
        something.
          method_name
      RUBY
    end

    it 'does not err on method call with no dots' do
      expect_no_offenses('puts something')
    end

    it 'does not err on method call without a method name' do
      expect_offense(<<~RUBY)
        l
        .(1)
        ^ Place the . on the previous line, together with the method call receiver.
      RUBY

      expect_correction(<<~RUBY)
        l.
        (1)
      RUBY
    end

    it 'does not err on method call on same line' do
      expect_no_offenses('something.method_name')
    end

    it 'does not get confused by several lines of chained methods' do
      expect_no_offenses(<<~RUBY)
        File.new(something).
        readlines.map.
        compact.join("\n")
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for correct + opposite' do
        expect_offense(<<~RUBY)
          something
            &.method_name
            ^^ Place the &. on the previous line, together with the method call receiver.
        RUBY

        expect_correction(<<~RUBY)
          something&.
            method_name
        RUBY
      end

      it 'accepts trailing dot in multi-line method call' do
        expect_no_offenses(<<~RUBY)
          something&.
            method_name
        RUBY
      end
    end
  end
end
