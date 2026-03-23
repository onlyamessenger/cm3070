abstract class UseCaseFuture<Input, Output> {
  Future<Output> execute(Input input);
}
