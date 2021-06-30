using Data.Views;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class PagoEntity
    {
        public int PagoProcesId { get; set; }
        public int PagoBancoId { get; set; }
        public string CodOperacion { get; set; }
        public string CodDepositante { get; set; }
        public string NomDepositante { get; set; }
        public string Referencia { get; set; }
        public DateTime FecPago { get; set; }
        public int Cantidad { get; set; }
        public string Moneda { get; set; }
        public decimal MontoPago { get; set; }
        public string LugarPago { get; set; }
        public int EntidadRecaudaID { get; set; }
        public string EntidadRecaudaDesc { get; set; }
        public int? CtaDepositoID { get; set; }
        public string NumeroCuenta { get; set; }
        public bool Anulado { get; set; }
        public int? NroSIAF { get; set; }
        public TipoPago I_TipoPago { get; set; }
        public int ConceptoPagoId { get; set; }
        public string ConceptoPagoDesc { get; set; }

        private readonly VW_Pagos vW_Pagos;

        public PagoEntity()
        {
            vW_Pagos = new VW_Pagos();
        }

        public PagoEntity(VW_Pagos tabla)
        {
            this.PagoProcesId = tabla.I_PagoProcesID;
            this.PagoBancoId = tabla.I_PagoBancoID;
            this.CodOperacion = tabla.C_CodOperacion;
            this.CodDepositante = tabla.C_CodDepositante;
            this.NomDepositante = tabla.T_NomDepositante;
            this.Referencia = tabla.C_Referencia;
            this.FecPago = tabla.D_FecPago;
            this.Cantidad = tabla.I_Cantidad;
            this.Moneda = tabla.C_Moneda;
            this.MontoPago = tabla.I_MontoPagado;
            this.LugarPago = tabla.T_LugarPago;
            this.EntidadRecaudaID = tabla.I_EntidadFinanID;
            this.EntidadRecaudaDesc = tabla.T_EntidadDesc;
            this.CtaDepositoID = tabla.I_CtaDepositoID;
            this.NumeroCuenta = tabla.C_NumeroCuenta;
            this.Anulado = tabla.B_Anulado;
            this.NroSIAF = tabla.N_NroSIAF;
            this.I_TipoPago = tabla.I_ObligacionAluID.HasValue ? TipoPago.Obligacion: TipoPago.Tasa;
            //this. = tabla.;
            //this. = tabla.;
            //this. = tabla.;
            //this. = tabla.;
            //this. = tabla.;
            //this. = tabla.;
        }
    }
}
