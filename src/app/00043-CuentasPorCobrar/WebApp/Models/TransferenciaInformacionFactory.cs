using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public static class TransferenciaInformacionFactory
    {
        public static ITransferenciaInformacion Get(int entidadFinanciera)
        {
            ITransferenciaInformacion transferenciaInformacion;
            if (Constantes.BCP_ID == 1)
            {

            }
            switch (entidadFinanciera)
            {
                case Constantes.BANCO_COMERCIO_ID:
                    transferenciaInformacion = new TransferenciaInformacionBcoComercio();
                    break;
                case Constantes.BCP_ID:
                    transferenciaInformacion = new TransferenciaInformacionBCP();
                    break;
                default:
                    throw new InvalidOperationException();
            }

            return transferenciaInformacion;
        }
    }
}