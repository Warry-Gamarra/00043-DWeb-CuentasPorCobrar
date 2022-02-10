using Data.Types;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public class ImportacionPagoResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string Icon { get; set; }
        public string Color { get; set; }
        public string Display { get; set; }

        public IEnumerable<PagoObligacionObsEntity> ListaResultadosOblig { get; }
        public IEnumerable<PagoTasaObsEntity> ListaResultadosTasas { get; }

        public ImportacionPagoResponse() { }

        public ImportacionPagoResponse(IEnumerable<DataPagoObligacionesResult> spResult)
        {
            ListaResultadosOblig = spResult.Select(x => new PagoObligacionObsEntity() {
                id = x.id,
                I_ProcesoID = x.I_ProcesoID,
                I_ObligacionAluID = x.I_ObligacionAluID,
                C_CodOperacion = x.C_CodOperacion,
                C_CodDepositante = x.C_CodDepositante,
                T_NomDepositante = x.T_NomDepositante,
                C_Referencia = x.C_Referencia,
                D_FecPago = x.D_FecPago,
                I_Cantidad = x.I_Cantidad,
                C_Moneda = x.C_Moneda,
                I_MontoOblig = x.I_MontoOblig,
                I_MontoPago = x.I_MontoPago,
                I_InteresMora = x.I_InteresMora,
                T_LugarPago = x.T_LugarPago,
                I_EntidadFinanID = x.I_EntidadFinanID,
                I_CtaDepositoID = x.I_CtaDepositoID,
                B_Pagado = x.B_Pagado,
                B_Success = x.B_Success,
                T_ErrorMessage = x.T_ErrorMessage,
                T_InformacionAdicional = x.T_InformacionAdicional,
                D_FecVencto = x.D_FecVencto,
                T_ProcesoDesc = x.T_ProcesoDesc
            });

            var errors = ListaResultadosOblig.Where(x => !x.B_Success).Count();

            Success = errors == ListaResultadosOblig.Count() ? false : true;

            Message = String.Format("Se han analizado \"{0}\" pago(s). Se han registrado \"{1}\" pago(s).",
                spResult.Count(), spResult.Count() - errors);
        }

        public ImportacionPagoResponse(IEnumerable<DataPagoTasasResult> spResult)
        {
            ListaResultadosTasas = spResult.Select(x => new PagoTasaObsEntity()
            {
                id = x.id,
                I_TasaUnfvID = x.I_TasaUnfvID,
                C_CodDepositante = x.C_CodDepositante,
                T_NomDepositante = x.T_NomDepositante,
                C_CodTasa = x.C_CodTasa,
                T_TasaDesc = x.T_TasaDesc,
                C_CodOperacion = x.C_CodOperacion,
                C_Referencia = x.C_Referencia,
                I_EntidadFinanID = x.I_EntidadFinanID,
                I_CtaDepositoID = x.I_CtaDepositoID,
                D_FecPago = x.D_FecPago,
                I_Cantidad = x.I_Cantidad,
                C_Moneda = x.C_Moneda,
                I_MontoPago = x.I_MontoPago,
                I_InteresMora = x.I_InteresMora,
                T_LugarPago = x.T_LugarPago,
                T_InformacionAdicional = x.T_InformacionAdicional,
                B_Success = x.B_Success,
                T_ErrorMessage = x.T_ErrorMessage,
                C_CodigoInterno = x.C_CodigoInterno
            });

            var errors = ListaResultadosTasas.Where(x => !x.B_Success).Count();

            Success = errors == ListaResultadosTasas.Count() ? false : true;

            Message = String.Format("Se han analizado \"{0}\" pago(s). Se han registrado \"{1}\" pago(s).",
                spResult.Count(), spResult.Count() - errors);
        }
    }
}
