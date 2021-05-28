using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class DevolucionPago
    {
        public int? DevolucionId { get; set; }
        public int EntidadRecaudadoraId { get; set; }
        public string EntidadRecaudadoraDesc { get; set; }
        public int PagoReferenciaId { get; set; }
        public string ReferenciaPago { get; set; }
        public string ConceptoPago { get; set; }
        public string Clasificador { get; set; }
        public DateTime FecPagoRef { get; set; }
        public decimal MontoDevolucion { get; set; }
        public DateTime FecAprueba { get; set; }
        public DateTime FecDevuelve { get; set; }
        public string NroSIAF { get; set; }

    }
}
