using Domain.Helpers;
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
            if (Bancos.BCP_ID == 1)
            {

            }
            switch (entidadFinanciera)
            {
                case Bancos.BANCO_COMERCIO_ID:
                    transferenciaInformacion = new TransferenciaInformacionBcoComercio();
                    break;
                case Bancos.BCP_ID:
                    transferenciaInformacion = new TransferenciaInformacionBCP();
                    break;
                default:
                    throw new NotImplementedException("Ha ocurrido un error al identificar el Banco.");
            }

            return transferenciaInformacion;
        }
    }
}