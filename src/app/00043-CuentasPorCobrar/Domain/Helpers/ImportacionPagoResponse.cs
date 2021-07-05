using Data.Types;
using Domain.Entities;
using System;
using System.Collections.Generic;
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

        public IEnumerable<PagoObligacionObsEntity> ListaResultados { get; }

        public ImportacionPagoResponse() { }

        public ImportacionPagoResponse(IEnumerable<DataPagoObligacionesResult> spResult)
        {
            ListaResultados = spResult.Select(x => new PagoObligacionObsEntity() {
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
                T_LugarPago = x.T_LugarPago,
                I_EntidadFinanID = x.I_EntidadFinanID,
                I_CtaDepositoID = x.I_CtaDepositoID,
                B_Pagado = x.B_Pagado,
                B_Success = x.B_Success,
                T_ErrorMessage = x.T_ErrorMessage
            });

            var errors = ListaResultados.Where(x => !x.B_Success).Count();

            Success = errors == ListaResultados.Count() ? false : true;

            Message = String.Format("Se han analizado \"{0}\" pago(s). Se han registrado \"{1}\" pago(s).",
                spResult.Count(), spResult.Count() - errors);
        }
    }
}
