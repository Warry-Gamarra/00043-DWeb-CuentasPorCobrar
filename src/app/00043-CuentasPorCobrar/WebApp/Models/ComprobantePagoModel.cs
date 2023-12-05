using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class ComprobantePagoModel
    {
        public int pagoBancoID { get; set; }

        public string entidadDesc { get; set; }

        public string numeroCuenta { get; set; }

        public string codOperacion { get; set; }

        public string codigoInterno { get; set; }

        public string codDepositante { get; set; }

        public string nomDepositante { get; set; }

        public DateTime fecPago { get; set; }

        public decimal montoPagado { get; set; }

        public decimal interesMoratorio { get; set; }

        public decimal montoTotal
        {
            get
            {
                return montoPagado + interesMoratorio;
            }
        }

        public string lugarPago { get; set; }

        public string condicionPago { get; set; }

        public TipoPago tipoPago { get; set; }

        public int? comprobantePagoID { get; set; }

        public int? numeroSerie { get; set; }

        public int? numeroComprobante { get; set; }

        public DateTime? fechaEmision { get; set; }

        public bool? esGravado { get; set; }

        public string tipoComprobanteDesc { get; set; }

        public string estadoComprobanteDesc { get; set; }

        public string comprobantePago
        {
            get
            {
                return comprobantePagoID.HasValue ? String.Format("{0} - {1}", numeroSerie.Value, numeroComprobante.Value) : "---";
            }
        }
    }
}