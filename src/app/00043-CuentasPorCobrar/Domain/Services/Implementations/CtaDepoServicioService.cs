using Data.Tables;
using Data.Views;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class CtaDepoServicioService : ICtaDepoServicioService
    {
        public readonly int ObligacionPregrado = 1;

        private readonly int ObligacionPosgrado = 1;

        private readonly int BCPTasas = 22;

        private int[] serviciosExcluidos()
        {
            return new int[] { ObligacionPregrado, ObligacionPosgrado, BCPTasas };
        }

        public IEnumerable<CtaDepoServicioDto> listaCtaDepoServicio()
        {
            var lista = VW_Servicio_X_CuentaDeposito.GetAll();

            var result = lista.Select(s => new CtaDepoServicioDto()
            {
                ctaDepoServicioID = s.I_CtaDepoServicioID,
                entidadDesc = s.T_EntidadDesc,
                numeroCuenta = s.C_NumeroCuenta,
                codServicio = s.C_CodServicio,
                descServ = s.T_DescServ,
                habilitado = s.B_Habilitado
            });

            return result;
        }
    }
}
