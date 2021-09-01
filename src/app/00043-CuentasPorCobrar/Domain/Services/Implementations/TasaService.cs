using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Procedures;
using Data.Types;
using Data.Views;
using Domain.Entities;
using Domain.Helpers;

namespace Domain.Services.Implementations
{
    public class TasaService : ITasaService
    {
        public IEnumerable<TasaDTO> listar_TasasHabilitadas()
        {
            var lista = VW_Tasas.GetHabilitados();

            IEnumerable<TasaDTO> result = null;

            if (lista != null)
            {
                result = lista.Select(t => Mapper.VW_Tasas_To_TasaDTO(t));
            }

            return result;
        }

        public ImportacionPagoResponse Grabar_Pago_Tasas(List<PagoTasaEntity> dataPagoTasas, string observacion, int currentUserID)
        {
            ImportacionPagoResponse result;

            var grabarPago = new USP_I_GrabarPagoTasas()
            {
                UserID = currentUserID
            };

            try
            {
                var dataTable = Mapper.PagoTasaEntity_To_DataTable(dataPagoTasas.Where(x => x.B_Correcto).ToList());

                var spResult = grabarPago.Execute(dataTable, observacion, currentUserID).ToList();

                var pagosObservados = dataPagoTasas.Where(x => !x.B_Correcto)
                    .Select(x => new DataPagoTasasResult()
                    {
                        C_CodDepositante = x.C_CodDepositante,
                        T_NomDepositante = x.T_NomDepositante,
                        C_CodTasa = x.C_CodTasa,
                        T_TasaDesc = x.T_TasaDesc,
                        C_CodOperacion = x.C_CodOperacion,
                        C_Referencia = x.C_CodOperacion,
                        I_EntidadFinanID = x.I_EntidadFinanID,
                        I_CtaDepositoID = x.I_CtaDepositoID,
                        D_FecPago = x.D_FecPago,
                        I_Cantidad = x.I_Cantidad,
                        C_Moneda = x.C_Moneda,
                        I_MontoPago = x.I_MontoPago,
                        I_InteresMora = x.I_InteresMora,
                        T_LugarPago = x.T_LugarPago,
                        T_InformacionAdicional = x.T_InformacionAdicional,
                        B_Success = false,
                        T_ErrorMessage = x.T_ErrorMessage
                    });

                spResult.AddRange(pagosObservados);

                result = new ImportacionPagoResponse(spResult);
            }
            catch (Exception ex)
            {
                result = new ImportacionPagoResponse()
                {
                    Success = false,
                    Message = ex.Message
                };
            }

            return result;
        }
    }
}
