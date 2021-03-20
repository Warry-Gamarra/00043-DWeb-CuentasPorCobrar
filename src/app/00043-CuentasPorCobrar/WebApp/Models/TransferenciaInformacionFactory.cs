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

            switch (entidadFinanciera)
            {
                case 1:
                    transferenciaInformacion = new TransferenciaInformacionBcoComercio();
                    break;
                default:
                    throw new InvalidOperationException();
            }

            return transferenciaInformacion;
        }
    }
}