using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class DetalleComprobanteDTO
    {
        public DetalleComprobanteDTO(string concepto, int cantidad, decimal montoPagado, decimal interesMoratorio, decimal igv, string codTasa)
        {
            this.concepto = String.IsNullOrEmpty(concepto) ? "-" : concepto;

            this.codTasa = String.IsNullOrEmpty(codTasa) ? "-" : codTasa;

            this.cantidad = cantidad == 0 ? 1 : cantidad;

            montoTotal = montoPagado + interesMoratorio;

            montoTotalUnitario = Math.Round(montoTotal / cantidad, 2);

            montoIGVUnitario = Math.Round((montoTotalUnitario * igv) / (1 + igv), 2);
        }

        public string concepto { get; }

        public string codTasa { get; }

        public decimal montoUnitario
        {
            get
            {
                return montoTotalUnitario - montoIGVUnitario;
            }
        }

        public decimal montoIGVUnitario { get; }

        public decimal montoTotalUnitario { get; }

        public int cantidad { get; }

        public decimal montoUnitarioTotal
        { 
            get
            {
                return montoUnitario * cantidad;
            }
        }

        public decimal montoIGVTotal 
        { 
            get
            {
                return montoIGVUnitario * cantidad;
            }
        }

        public decimal montoTotal { get; }
    }
}
