using Data.Procedures;
using Data.Views;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI.WebControls;

namespace Domain.Entities
{
    public class PagoEntity
    {
        public int NroCuota { get; set; }
        public int? CtaDepositoID { get; set; }
        public string NumeroCuenta { get; set; }
        public string CodOperacion { get; set; }
        public string CodDepositante { get; set; }
        public int PagoBancoId { get; set; }
        public string NomDepositante { get; set; }
        public DateTime FecPago { get; set; }
        public int Cantidad { get; set; }
        public string Periodo { get; set; }
        public int ProcesoID { get; set; }
        public int? CuotaPagoID { get; set; }
        public string CodAlumno { get; set; }
        public string CodRc { get; set; }
        public string Anio { get; set; }
        public string ConceptoPagoDesc { get; set; }
        public DateTime FecVencto { get; set; }
        public string Moneda { get; set; }
        public string LugarPago { get; set; }
        public decimal MontoPago { get; set; }
        public string CodServicio { get; set; }
        public string Referencia { get; set; }
        public int EntidadRecaudaID { get; set; }
        public string EntidadRecaudaDesc { get; set; }
        public string InformacionAdicional { get; set; }
        public TipoPago I_TipoPago { get; set; }
        public int? NroSIAF { get; set; }
        
        private readonly VW_Pagos vW_Pagos;

        public PagoEntity()
        {
            vW_Pagos = new VW_Pagos();
        }

        public PagoEntity(VW_Pagos tabla)
        {
            this.NroCuota = tabla.I_NroOrden;
            this.PagoBancoId = tabla.I_PagoBancoID;
            this.CtaDepositoID = tabla.I_CtaDepositoID;
            this.CodOperacion = tabla.C_CodOperacion;
            this.CodDepositante = string.IsNullOrEmpty(tabla.C_CodDepositante) ? tabla.C_CodAlu : tabla.C_CodDepositante;
            this.NomDepositante = string.IsNullOrEmpty(tabla.T_NomAlumno) ? tabla.T_NomDepositante : tabla.T_NomAlumno;
            this.Referencia = string.IsNullOrEmpty(tabla.C_Referencia) ? "" : tabla.C_Referencia;
            this.FecPago = tabla.D_FecPago;
            this.FecVencto = tabla.D_FecVencto;
            this.Cantidad = tabla.I_Cantidad;
            this.Moneda = tabla.C_Moneda;
            this.MontoPago = tabla.I_MontoPagado;
            this.LugarPago = tabla.T_LugarPago;
            this.EntidadRecaudaID = tabla.I_EntidadFinanID;
            this.EntidadRecaudaDesc = string.IsNullOrEmpty(tabla.T_EntidadDesc) ? "" : tabla.T_EntidadDesc;
            this.NumeroCuenta = tabla.C_NumeroCuenta;
            this.I_TipoPago = TipoPago.Obligacion;
            this.CodServicio = tabla.C_CodServicio;
            this.ProcesoID = tabla.I_ProcesoID;
            this.CuotaPagoID = tabla.I_CuotaPagoID;
            this.InformacionAdicional = tabla.T_InformacionAdicional;
            this.Anio = tabla.I_Anio.ToString();
            this.Periodo = tabla.C_Periodo;
            this.CodRc = tabla.C_RcCod;
            this.CodAlumno = tabla.C_CodAlu;
            this.ConceptoPagoDesc = tabla.T_Concepto;
        }

        public PagoEntity(VW_PagosParaDevolucion sp)
        {
            this.PagoBancoId = sp.I_PagoBancoID;
            this.CodOperacion = sp.C_CodOperacion;
            this.CodDepositante = sp.C_CodDepositante;
            this.NomDepositante = sp.T_NomDepositante;
            this.EntidadRecaudaID = sp.I_EntidadFinanID;
            this.EntidadRecaudaDesc = sp.T_EntidadDesc;
            this.CtaDepositoID = sp.I_CtaDepositoID;
            this.NumeroCuenta = sp.C_NumeroCuenta;
            this.FecPago = sp.D_FecPago;
            this.Cantidad = sp.I_Cantidad;
            this.Moneda = sp.C_Moneda;
            this.ConceptoPagoDesc = sp.T_Concepto;
            this.LugarPago = sp.T_LugarPago;
            this.MontoPago = sp.I_MontoPago + sp.I_InteresMora;
            this.InformacionAdicional = sp.T_InformacionAdicional;
            this.I_TipoPago = sp.I_TipoPagoID == 133 ? TipoPago.Obligacion : (sp.I_TipoPagoID == 134 ? TipoPago.Tasa : 
                throw new NotImplementedException("Tipo de pago desconocido"));
        }
    }
}
