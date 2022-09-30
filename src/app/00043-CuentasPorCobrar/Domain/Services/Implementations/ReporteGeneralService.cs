using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReporteGeneralService : IReporteGeneralService
    {
        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DiaDTO> ResumenAnualPagoDeObligaciones_X_Dia(int anio, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Dia.Execute(anio, entidadFinanID, ctaDepositoID, condicionPagoID);

            var result = lista.Select(x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Dia_To_ResumenAnualPagoDeObligaciones_X_DiaDTO(x));

            return result;
        }

        public IEnumerable<CantidadDePagosRegistrados_X_DiaDTO> CantidadDePagosRegistrados_X_Dia(int anio, int tipoPago, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID)
        {
            var lista = USP_S_CantidadDePagosRegistrados_X_Dia.Execute(anio, tipoPago, entidadFinanID, ctaDepositoID, condicionPagoID);

            var result = lista.Select(x => Mapper.USP_S_CantidadDePagosRegistrados_X_Dia_To_CantidadDePagosRegistrados_X_DiaDTO(x));

            return result;
        }
    }
}
