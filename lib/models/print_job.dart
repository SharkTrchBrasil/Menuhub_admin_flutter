// Crie um modelo para os dados do job para ter tipagem forte
class PrintJob {
  final int id;
  final String destination;
  PrintJob({required this.id, required this.destination});
}

class PrintJobPayload {
  final int orderId;
  final List<PrintJob> jobs;
  PrintJobPayload({required this.orderId, required this.jobs});
}